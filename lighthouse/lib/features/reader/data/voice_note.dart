import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import '../../../core/log.dart';

/// The microphone could not record: no permission, or nothing to record
/// with (on Linux, no `parecord`: PulseAudio or PipeWire's pulse layer).
class RecordingFailed implements Exception {
  const RecordingFailed(this.reason);

  final String reason;

  @override
  String toString() => 'RecordingFailed: $reason';
}

/// Records a voice note into a file of its own.
abstract interface class NoteRecorder {
  /// Starts recording into a new file in [dir]; returns its name (in
  /// [dir]). Throws [RecordingFailed].
  Future<String> start(Directory dir);

  /// Ends the recording, the file complete; how long it is.
  Future<Duration> stop();

  /// Ends the recording and drops the file.
  Future<void> cancel();
}

/// Plays one voice note at a time.
abstract interface class NotePlayer {
  /// The file playing (its path); null when none.
  ValueListenable<String?> get playing;

  /// Plays [file], stopping whatever played.
  Future<void> play(File file);

  Future<void> stop();
}

/// Where voice notes are kept: beside the reader's other files, on this
/// device only.
final voiceNotesDirectoryProvider = FutureProvider<Directory>(
  (_) async => Directory(
    '${(await getApplicationSupportDirectory()).path}/reader/voice-notes',
  ),
);

final noteRecorderProvider = Provider<NoteRecorder>((ref) {
  final recorder = MicNoteRecorder();
  ref.onDispose(() => unawaited(recorder.dispose()));
  return recorder;
});

final notePlayerProvider = Provider<NotePlayer>((ref) {
  final player = MpvNotePlayer();
  ref.onDispose(() => unawaited(player.dispose()));
  return player;
});

/// The microphone, through the record package. Android records AAC (an
/// .m4a, small). Linux takes the raw sound from `parecord` and writes a
/// WAV itself: the package's file mode there needs ffmpeg installed, which
/// a desktop may not have.
class MicNoteRecorder implements NoteRecorder {
  AudioRecorder? _recorder;
  AudioRecorder get _mic => _recorder ??= AudioRecorder();

  /// Mono, at a rate made for speech: a minute is under 2 MB as WAV.
  static const _sampleRate = 16000;

  File? _file;
  final _clock = Stopwatch();
  BytesBuilder? _pcm;
  Completer<void>? _streamDone;

  bool get _raw => Platform.isLinux;

  @override
  Future<String> start(Directory dir) async {
    if (!await _mic.hasPermission()) {
      throw const RecordingFailed('no permission to use the microphone');
    }
    await dir.create(recursive: true);
    final name =
        '${DateTime.now().millisecondsSinceEpoch}.${_raw ? 'wav' : 'm4a'}';
    final file = File('${dir.path}/$name');
    try {
      if (_raw) {
        final pcm = BytesBuilder(copy: false);
        final done = Completer<void>();
        final stream = await _mic.startStream(
          const RecordConfig(
            encoder: AudioEncoder.pcm16bits,
            sampleRate: _sampleRate,
            numChannels: 1,
          ),
        );
        stream.listen(
          pcm.add,
          onDone: done.complete,
          onError: (Object e) {
            if (!done.isCompleted) done.complete();
          },
        );
        _pcm = pcm;
        _streamDone = done;
      } else {
        await _mic.start(
          const RecordConfig(numChannels: 1, sampleRate: 44100),
          path: file.path,
        );
      }
    } on Object catch (e) {
      log.warning('reader', 'could not record', e);
      throw RecordingFailed('$e');
    }
    _file = file;
    _clock
      ..reset()
      ..start();
    return name;
  }

  @override
  Future<Duration> stop() async {
    _clock.stop();
    final file = _file;
    _file = null;
    await _mic.stop();
    if (_raw && file != null) {
      // The stream ends once parecord is gone.
      await _streamDone?.future.timeout(
        const Duration(seconds: 2),
        onTimeout: () {},
      );
      final pcm = _pcm?.takeBytes() ?? Uint8List(0);
      _pcm = null;
      await file.writeAsBytes(wavFile(pcm, sampleRate: _sampleRate));
      return pcmLength(pcm.length, sampleRate: _sampleRate);
    }
    return _clock.elapsed;
  }

  @override
  Future<void> cancel() async {
    _clock.stop();
    final file = _file;
    _file = null;
    _pcm = null;
    await _mic.cancel();
    if (file != null && file.existsSync()) await file.delete();
  }

  Future<void> dispose() async => _recorder?.dispose();
}

/// How long [bytes] of 16-bit mono PCM at [sampleRate] play.
Duration pcmLength(int bytes, {required int sampleRate}) =>
    Duration(microseconds: bytes ~/ 2 * 1000000 ~/ sampleRate);

/// [pcm] (16-bit little-endian samples, [channels] interleaved) as a WAV
/// file.
Uint8List wavFile(Uint8List pcm, {required int sampleRate, int channels = 1}) {
  const bits = 16;
  final header = ByteData(44);
  void ascii(int at, String text) {
    for (var i = 0; i < text.length; i++) {
      header.setUint8(at + i, text.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  header.setUint32(4, 36 + pcm.length, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  header
    ..setUint32(16, 16, Endian.little) // Size of this chunk.
    ..setUint16(20, 1, Endian.little) // PCM.
    ..setUint16(22, channels, Endian.little)
    ..setUint32(24, sampleRate, Endian.little)
    ..setUint32(28, sampleRate * channels * bits ~/ 8, Endian.little)
    ..setUint16(32, channels * bits ~/ 8, Endian.little)
    ..setUint16(34, bits, Endian.little);
  ascii(36, 'data');
  header.setUint32(40, pcm.length, Endian.little);
  return (BytesBuilder(copy: false)
        ..add(header.buffer.asUint8List())
        ..add(pcm))
      .takeBytes();
}

/// Plays voice notes with mpv (media_kit), as the app plays everything.
/// Its own player, made on the first note played: it does not touch the
/// video or music playing.
class MpvNotePlayer implements NotePlayer {
  Player? _player;
  final _playing = ValueNotifier<String?>(null);
  StreamSubscription<bool>? _completed;

  @override
  ValueListenable<String?> get playing => _playing;

  Player get _mpv {
    final player = _player;
    if (player != null) return player;
    final made = Player(
      configuration: const PlayerConfiguration(title: 'Lighthouse'),
    );
    _completed = made.stream.completed.listen((done) {
      if (done) _playing.value = null;
    });
    return _player = made;
  }

  @override
  Future<void> play(File file) async {
    _playing.value = file.path;
    try {
      await _mpv.open(Media(file.path));
    } on Object catch (e) {
      log.warning('reader', 'could not play a voice note', e);
      _playing.value = null;
    }
  }

  @override
  Future<void> stop() async {
    _playing.value = null;
    await _player?.stop();
  }

  Future<void> dispose() async {
    await _completed?.cancel();
    await _player?.dispose();
    _playing.dispose();
  }
}
