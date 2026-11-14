#!/usr/bin/env bash
# Generates the small test library used by the automated tests.
# The output (fixtures/media) is committed; run this again only when you
# change what is generated. Output is deterministic (bitexact, no dates).
#
#   movies/Test Movie (2020)/   H.264 + 2 audio tracks (eng, por) + embedded
#                               and external subtitles
#   movies/HEVC Movie (2021)/   HEVC 10-bit, for the transcode path
#   shows/Test Show/Season 01/  3 episodes (next episode, Next Up)
#   music/Test Artist/Test Album/  2 tagged tracks
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)/fixtures/media"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
rm -rf "$root"
mkdir -p "$root"

ff() { ffmpeg -hide_banner -loglevel error -y "$@"; }
# Flags that keep the files byte-for-byte reproducible.
exact=(-fflags +bitexact -flags:v +bitexact -flags:a +bitexact -map_metadata -1)
x264=(-c:v libx264 -preset veryfast -crf 35 -pix_fmt yuv420p -threads 1 -x264-params "keyint=25")

srt() { # srt <file> <text prefix>
  cat > "$1" <<SRT
1
00:00:00,500 --> 00:00:04,000
$2 subtitle one

2
00:00:04,500 --> 00:00:09,000
$2 subtitle two
SRT
}

# --- Movie with two audio tracks and subtitles ------------------------------
d="$root/movies/Test Movie (2020)"
mkdir -p "$d"
srt "$tmp/eng.srt" "English"
ff -f lavfi -i "testsrc2=size=320x180:rate=25:duration=10" \
   -f lavfi -i "sine=frequency=440:duration=10" \
   -f lavfi -i "sine=frequency=660:duration=10" \
   -i "$tmp/eng.srt" \
   -map 0:v -map 1:a -map 2:a -map 3:s \
   "${x264[@]}" -c:a aac -b:a 32k -ac 1 -c:s srt \
   -metadata:s:a:0 language=eng -metadata:s:a:0 title="English" \
   -metadata:s:a:1 language=por -metadata:s:a:1 title="Português" \
   -metadata:s:s:0 language=eng \
   "${exact[@]}" "$d/Test Movie (2020).mkv"
srt "$d/Test Movie (2020).por.srt" "Português"

# --- HEVC 10-bit movie --------------------------------------------------------
d="$root/movies/HEVC Movie (2021)"
mkdir -p "$d"
ff -f lavfi -i "testsrc2=size=320x180:rate=25:duration=5" \
   -f lavfi -i "sine=frequency=330:duration=5" \
   -c:v libx265 -preset ultrafast -crf 35 -pix_fmt yuv420p10le \
   -x265-params "log-level=error:pools=none:frame-threads=1" \
   -c:a aac -b:a 32k -ac 1 -metadata:s:a:0 language=eng \
   "${exact[@]}" "$d/HEVC Movie (2021).mkv"

# --- Show: 3 episodes ---------------------------------------------------------
d="$root/shows/Test Show/Season 01"
mkdir -p "$d"
for n in 1 2 3; do
  ff -f lavfi -i "testsrc2=size=320x180:rate=25:duration=6" \
     -f lavfi -i "sine=frequency=$((200 + n * 100)):duration=6" \
     "${x264[@]}" -c:a aac -b:a 32k -ac 1 -metadata:s:a:0 language=eng \
     "${exact[@]}" "$d/Test Show S01E0$n.mkv"
done

# --- Music: 2 tagged tracks ---------------------------------------------------
d="$root/music/Test Artist/Test Album"
mkdir -p "$d"
for n in 1 2; do
  ff -f lavfi -i "sine=frequency=$((300 + n * 120)):duration=8" \
     -c:a libmp3lame -b:a 32k -ac 1 "${exact[@]}" \
     -metadata artist="Test Artist" -metadata album_artist="Test Artist" \
     -metadata album="Test Album" -metadata title="Track $n" \
     -metadata track="$n" -metadata date="2020" \
     -id3v2_version 3 -write_xing 0 \
     "$d/0$n - Track $n.mp3"
done

du -sh "$root"
