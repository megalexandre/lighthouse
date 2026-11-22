import 'dart:async';

import 'package:flutter/widgets.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/ticks.dart';
import '../data/audio_focus.dart';
import '../data/media_controls.dart';
import '../data/player_engine.dart';

/// One playback's manners with the rest of the phone: it takes turns at
/// the sound with other apps and, for music, shows in the system's media
/// controls (which keep it playing with the screen off).
class SystemMedia implements MediaCommands {
  SystemMedia(
    this._engine, {
    required this._focus,
    required this._controls,
    required this.onNext,
    required this.onPrevious,
    required this.onPlay,
  }) {
    _subscriptions.addAll([
      _engine.playingStream.distinct().listen(_onPlaying),
      _engine.positionStream.listen(_onPosition),
      _engine.bufferingStream.listen((buffering) {
        _buffering = buffering;
        _announce();
      }),
      _engine.durationStream.listen((_) => _announce()),
      _engine.rateStream.listen((_) => _announce()),
      _focus.events.listen(_onFocus),
    ]);
  }

  final PlayerEngine _engine;
  final AudioFocus _focus;
  final MediaControls _controls;

  /// The controls' buttons: what they do is the player's business.
  final Future<void> Function() onNext;
  final Future<void> Function() onPrevious;
  final Future<void> Function() onPlay;

  final _subscriptions = <StreamSubscription<Object?>>[];

  /// The song in the system's controls; null: none (video has none).
  BaseItemDto? _song;
  Uri? _art;
  bool _hasNext = false;
  bool _buffering = false;

  /// Between two songs: not a pause, for the controls.
  bool _changing = false;

  /// Paused by something short (a call): plays again when it ends.
  bool _resumeWhenFree = false;

  /// The user dismissed the controls: they come back when it plays.
  bool _dismissed = false;

  /// What the controls were last told, and how long ago, to notice a seek:
  /// they move the position on by themselves.
  ({Duration position, bool playing, double rate})? _told;
  final _sinceTold = Stopwatch();

  bool get _isVideo => _song == null;

  /// [item] is what plays now.
  void follow(BaseItemDto item, {Uri? art}) {
    _changing = false;
    _hasNext = false;
    _song = item.type == BaseItemKind.audio ? item : null;
    _art = art;
    _announce();
  }

  /// A new song is on its way, in place of this one.
  void changing() {
    _changing = true;
    _announce();
  }

  /// Whether there is a song after this one.
  // ignore: use_setters_to_change_properties
  void setHasNext({required bool hasNext}) {
    _hasNext = hasNext;
    _announce();
  }

  /// The playback ended: no controls, and the sound is free for others.
  void end() {
    _song = null;
    _changing = false;
    _resumeWhenFree = false;
    _told = null;
    _controls.clear(this);
    unawaited(_focus.release(this));
  }

  void dispose() {
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    end();
  }

  void _onPlaying(bool playing) {
    if (!playing) return _announce();
    _dismissed = false;
    _resumeWhenFree = false;
    _announce();
    unawaited(() async {
      if (!await _focus.request(this)) await _engine.pause();
    }());
  }

  void _onFocus(AudioFocusEvent event) {
    switch (event) {
      case AudioFocusEvent.lostForNow:
        if (!_engine.playing) return;
        unawaited(_engine.pause());
        _resumeWhenFree = true;
      case AudioFocusEvent.lost || AudioFocusEvent.headphonesGone:
        _resumeWhenFree = false;
        unawaited(_engine.pause());
      case AudioFocusEvent.regained:
        if (!_resumeWhenFree) return;
        _resumeWhenFree = false;
        // Video does not play in the background.
        if (_isVideo && !_inFront) return;
        unawaited(_engine.play());
    }
  }

  static bool get _inFront => switch (WidgetsBinding.instance.lifecycleState) {
    null || AppLifecycleState.resumed || AppLifecycleState.inactive => true,
    _ => false,
  };

  void _onPosition(Duration position) {
    final told = _told;
    if (told == null) return;
    final expected = told.playing
        ? told.position + _sinceTold.elapsed * told.rate
        : told.position;
    if ((position - expected).abs() > const Duration(milliseconds: 1500)) {
      _announce();
    }
  }

  void _announce() {
    final song = _song;
    if (song == null || _dismissed) return;
    final playing = _changing || _engine.playing;
    final position = _changing ? Duration.zero : _engine.position;
    final rate = _engine.rate;
    _told = (position: position, playing: playing, rate: rate);
    _sinceTold
      ..reset()
      ..start();
    final length = song.runTimeTicks;
    _controls.show(
      this,
      (
        id: song.id,
        title: song.name,
        artist: song.albumArtist,
        album: song.album,
        art: _art,
        duration: length == null ? null : ticksToDuration(length),
      ),
      (
        playing: playing,
        buffering: _changing || _buffering,
        position: position,
        rate: rate,
        hasNext: _hasNext,
      ),
    );
  }

  @override
  Future<void> play() => onPlay();

  @override
  Future<void> pause() {
    _resumeWhenFree = false;
    return _engine.pause();
  }

  @override
  Future<void> seek(Duration position) => _engine.seek(position);

  @override
  Future<void> next() => onNext();

  @override
  Future<void> previous() => onPrevious();

  /// Paused, the place kept (a pause is reported), the controls gone.
  @override
  Future<void> stop() async {
    _dismissed = true;
    _told = null;
    _controls.clear(this);
    await pause();
    unawaited(_focus.release(this));
  }
}
