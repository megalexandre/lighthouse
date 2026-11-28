#!/usr/bin/env python3
"""Writes the reader's page sounds into assets/sounds (then committed).

Made here, not recorded: no licence to track. Pure standard library (ffmpeg
only encodes the result) and reproducible: fixed seeds, bitexact encoding.

Paper does not hiss, it crackles: a page rubbing is thousands of tiny
clicks as fibres catch and let go, each a few milliseconds of bright noise,
at uneven loudness (a few loud ones, many faint), coming in bursts. So both
sounds are built from such grains, rather than from filtered steady noise:

  page_rustle.ogg  2 s of rubbing, looped while a page is dragged (its
                   volume following how fast it moves); seamless: grains
                   past the end wrap round to the start
  page_turn.ogg    a page turned: crackles as it lifts, the air it moves
                   (a low "whoosh" with a flutter), crackles as it bends
                   over, and a soft flap as it lands

Run again only to change the sounds: python3 tool/gen_page_sounds.py
"""

import math
import random
import struct
import subprocess
import sys
import tempfile
import wave
from pathlib import Path

RATE = 44100
OUT = Path(__file__).resolve().parent.parent / "assets" / "sounds"


class Biquad:
    """An RBJ biquad filter (band-pass with constant 0 dB peak, low-pass,
    high-pass), run sample by sample."""

    def __init__(self, kind, freq, q):
        w = 2 * math.pi * freq / RATE
        alpha = math.sin(w) / (2 * q)
        cos = math.cos(w)
        if kind == "band":
            b = (alpha, 0.0, -alpha)
        elif kind == "low":
            b = ((1 - cos) / 2, 1 - cos, (1 - cos) / 2)
        else:  # high
            b = ((1 + cos) / 2, -(1 + cos), (1 + cos) / 2)
        a0 = 1 + alpha
        self.b = [x / a0 for x in b]
        self.a = [-2 * cos / a0, (1 - alpha) / a0]
        self.x1 = self.x2 = self.y1 = self.y2 = 0.0

    def __call__(self, x):
        y = (self.b[0] * x + self.b[1] * self.x1 + self.b[2] * self.x2
             - self.a[0] * self.y1 - self.a[1] * self.y2)
        self.x2, self.x1 = self.x1, x
        self.y2, self.y1 = self.y1, y
        return y


def grain(rng, out, at, loud, low=1800, high=7500, wrap=False):
    """One fibre's click at sample [at]: 1-6 ms of noise, band-passed
    somewhere between [low] and [high] Hz, a sharp attack and a quick decay.
    [wrap]: what runs past the end comes back at the start (a loop)."""
    length = int(RATE * rng.uniform(0.001, 0.006))
    centre = math.exp(rng.uniform(math.log(low), math.log(high)))
    band = Biquad("band", centre, rng.uniform(0.8, 2.0))
    attack = max(1, int(RATE * 0.0003))
    for i in range(length + int(RATE * 0.002)):  # Plus the filter's ring.
        env = (i / attack if i < attack
               else math.exp(-(i - attack) / (length / 3)))
        y = band(rng.uniform(-1, 1) * env) * loud
        j = at + i
        if wrap:
            j %= len(out)
        elif j >= len(out):
            break
        out[j] += y


def loudness(rng):
    """How loud a grain is: mostly moderate, now and then a louder crack
    (a mildly heavy-tailed draw, as fibres snap). Too heavy a tail and a
    few cracks drown the rest: it ticks instead of rubbing."""
    return min(1.0, 0.18 * rng.random() ** -0.45)


def crackle(rng, out, start, end, rate_at, wrap=False, **band):
    """Grains from [start] to [end] (seconds), [rate_at](t) of them a
    second around time t (a Poisson process thinned to that rate)."""
    top = max(rate_at(start + (end - start) * k / 50) for k in range(51))
    t = start
    while True:
        t += rng.expovariate(top)
        if t >= end:
            return
        if rng.random() * top <= rate_at(t):
            grain(rng, out, int(t * RATE), loudness(rng), wrap=wrap, **band)


def whoosh(rng, out, start, end, peak):
    """The air a page moves: low noise (200-1200 Hz) swelling to [peak]
    seconds and away, fluttering as the sheet waves."""
    low = Biquad("low", 1200, 0.7)
    high = Biquad("high", 200, 0.7)
    n0, n1 = int(start * RATE), int(end * RATE)
    for j in range(n0, n1):
        t = j / RATE
        # Rises, then falls more slowly.
        side = (peak - start) if t < peak else (end - peak)
        env = math.exp(-((t - peak) / (side / 2.2)) ** 2)
        flutter = 1 + 0.35 * math.sin(2 * math.pi * 17 * t)
        out[j] += high(low(rng.uniform(-1, 1))) * env * flutter * 0.5


def flap(rng, out, at):
    """The page landing: a soft, dull pat (noise under 500 Hz, 60 ms)."""
    low = Biquad("low", 500, 0.9)
    for i in range(int(RATE * 0.08)):
        env = math.exp(-i / (RATE * 0.018))
        j = int(at * RATE) + i
        if j < len(out):
            out[j] += low(rng.uniform(-1, 1)) * env * 1.2


def soften(out, drive=3.0):
    """Rounds the loudest cracks off (a gentle tanh), so the rub as a whole
    can be louder without them stabbing out."""
    peak = max(abs(x) for x in out) or 1.0
    top = math.tanh(drive)
    return [math.tanh(drive * x / peak) / top for x in out]


def normalise(out, peak_db=-3.0):
    peak = max(abs(x) for x in out) or 1.0
    gain = 10 ** (peak_db / 20) / peak
    return [x * gain for x in out]


def rustle():
    rng = random.Random(7)
    seconds = 2.0
    out = [0.0] * int(RATE * seconds)

    # Bursts: the rate wanders between ~150 and ~1000 grains a second (they
    # overlap into a dry, crackling rub), on slow cycles that fit the loop
    # exactly (whole turns in 2 s).
    def rate(t):
        x = t / seconds * 2 * math.pi
        swell = (0.5 + 0.3 * math.sin(3 * x + 0.4)
                 + 0.2 * math.sin(7 * x + 1.9))
        return 150 + 850 * max(0.0, swell) ** 1.5

    crackle(rng, out, 0.0, seconds, rate, wrap=True)
    # A faint bed under the crackles, so the gaps are not dead silence (the
    # sheet still slides).
    bed = Biquad("band", 3500, 0.6)
    for j in range(len(out)):
        x = j / len(out) * 2 * math.pi
        out[j] += bed(rng.uniform(-1, 1)) * 0.04 * (1 + 0.5 * math.sin(3 * x))
    return normalise(soften(out))


def turn():
    rng = random.Random(11)
    seconds = 0.5
    out = [0.0] * int(RATE * seconds)
    # Lifting: a dense burst of crackles, dying away in ~80 ms.
    crackle(rng, out, 0.0, 0.12, lambda t: 900 * math.exp(-t / 0.035) + 60)
    whoosh(rng, out, 0.02, 0.46, peak=0.17)
    # Bending over the spine: a second, thinner run of crackles.
    crackle(rng, out, 0.12, 0.36,
            lambda t: 220 * math.exp(-((t - 0.22) / 0.06) ** 2) + 30,
            low=1500, high=6000)
    flap(rng, out, 0.37)
    # Ends at silence: a short fade past the flap.
    fade = int(RATE * 0.04)
    for i in range(fade):
        out[-fade + i] *= 1 - i / fade
    return normalise(out)


def write(name, samples):
    with tempfile.TemporaryDirectory() as tmp:
        wav = Path(tmp) / f"{name}.wav"
        with wave.open(str(wav), "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(b"".join(
                struct.pack("<h", max(-32767, min(32767, round(x * 32767))))
                for x in samples))
        subprocess.run(
            ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
             "-i", str(wav), "-map_metadata", "-1", "-fflags", "+bitexact",
             "-flags:a", "+bitexact", "-c:a", "libvorbis", "-q:a", "4",
             str(OUT / f"{name}.ogg")],
            check=True)


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    write("page_rustle", rustle())
    write("page_turn", turn())
    for f in sorted(OUT.iterdir()):
        print(f"{f.name}: {f.stat().st_size} bytes")
    return 0


if __name__ == "__main__":
    sys.exit(main())
