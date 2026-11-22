import 'dart:async';
import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/log.dart';

/// What happened to the right to make sound.
enum AudioFocusEvent {
  /// Another app plays from now on.
  lost,

  /// Something short has the sound (a call, a navigation voice).
  lostForNow,

  /// That something ended.
  regained,

  /// The headphones are gone: the sound would come out of the speaker.
  headphonesGone,
}

/// The right to make sound, which apps on a phone take turns at. Behind an
/// interface so tests can use a fake.
abstract interface class AudioFocus {
  /// Asks for it on [owner]'s behalf; false: refused (a call is on).
  Future<bool> request(Object owner);

  /// [owner] is done. Nothing when another asked meanwhile: the next
  /// episode's player starts before the last one is let go.
  Future<void> release(Object owner);

  Stream<AudioFocusEvent> get events;
}

final audioFocusProvider = Provider<AudioFocus>(
  (_) => Platform.isAndroid ? AndroidAudioFocus() : const FreeAudioFocus(),
);

/// A desktop: every app sounds at once.
class FreeAudioFocus implements AudioFocus {
  const FreeAudioFocus();

  @override
  Future<bool> request(Object owner) async => true;

  @override
  Future<void> release(Object owner) async {}

  @override
  Stream<AudioFocusEvent> get events => const Stream.empty();
}

class AndroidAudioFocus implements AudioFocus {
  AndroidAudioFocus() {
    unawaited(_listen());
  }

  final _events = StreamController<AudioFocusEvent>.broadcast();
  Object? _owner;

  late final Future<AudioSession> _session = () async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    return session;
  }();

  Future<void> _listen() async {
    final AudioSession session;
    try {
      session = await _session;
    } on PlatformException catch (e) {
      log.warning('player', 'no audio focus', e.message);
      return;
    }
    session.interruptionEventStream.listen((event) {
      final AudioFocusEvent? happened = switch ((event.begin, event.type)) {
        // Android lowers the volume itself (8 and up).
        (_, AudioInterruptionType.duck) => null,
        (true, AudioInterruptionType.pause) => AudioFocusEvent.lostForNow,
        (true, AudioInterruptionType.unknown) => AudioFocusEvent.lost,
        (false, _) => AudioFocusEvent.regained,
      };
      if (happened != null) _events.add(happened);
    });
    session.becomingNoisyEventStream.listen(
      (_) => _events.add(AudioFocusEvent.headphonesGone),
    );
  }

  @override
  Stream<AudioFocusEvent> get events => _events.stream;

  @override
  Future<bool> request(Object owner) async {
    _owner = owner;
    try {
      final session = await _session;
      if (await session.setActive(true)) return true;
      // The plugin keeps a refused request and would call the next one
      // granted.
      await session.setActive(false);
      return false;
    } on PlatformException catch (e) {
      // Better to play over another app than not to play.
      log.warning('player', 'could not ask for the audio focus', e.message);
      return true;
    }
  }

  @override
  Future<void> release(Object owner) async {
    if (!identical(_owner, owner)) return;
    _owner = null;
    try {
      await (await _session).setActive(false);
    } on PlatformException catch (e) {
      log.warning('player', 'could not let the audio focus go', e.message);
    }
  }
}
