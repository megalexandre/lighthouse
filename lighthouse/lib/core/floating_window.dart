import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'log.dart';

/// What happens to the floating window from outside the player: the
/// system shrank it (Android, the user went Home), gave it back its size,
/// or the user closed it; or one of its buttons was used (Android's, the
/// app draws none there).
enum FloatingEvent {
  entered,
  expanded,
  closed,
  playPause,
  seekBack,
  seekForward,
}

/// What the window floats with while a video plays: the picture's shape,
/// and its buttons (their labels for screen readers, in the app's language).
typedef FloatingOffer = ({
  double aspectRatio,
  bool playing,
  String play,
  String pause,
  String back10,
  String forward10,
});

/// The app's window shrunk to a small one over the others, only the
/// picture in it ("picture in picture"): a frameless window kept on top
/// on the desktop, the system's PiP on Android.
abstract interface class FloatingWindow {
  /// Whether it can float here (Android: the phone may have no PiP).
  Future<bool> supported();

  /// Leaving full screen first is the app's job (the desktop), or not
  /// needed (Android floats a full-screen activity as it is).
  bool get leavesFullScreen;

  /// Floats, the picture [aspectRatio] wide to 1 high. False: it did not
  /// (the user turned PiP off for the app).
  Future<bool> enter(double aspectRatio);

  /// Back to how the window was. On Android the app cannot grow the PiP
  /// window back by itself: it goes away, and the app with it, to the
  /// background.
  Future<void> leave();

  /// While a video plays: [offer]'s shape and buttons. Android also floats
  /// by itself when the user goes Home while it plays. Null: nothing plays.
  void offer(FloatingOffer? offer);

  /// The mouse button went down on the floating window: it follows the
  /// mouse until the button is let go (the desktop; it has no title bar).
  void startDragging();

  Stream<FloatingEvent> get events;

  void dispose();
}

final floatingWindowProvider = Provider<FloatingWindow>((ref) {
  final window = Platform.isAndroid
      ? AndroidFloatingWindow()
      : DesktopFloatingWindow();
  ref.onDispose(window.dispose);
  return window;
});

/// Whether the player offers to float, known once asked.
final floatingSupportedProvider = FutureProvider<bool>(
  (ref) => ref.watch(floatingWindowProvider).supported(),
);

/// A frameless window kept above the others, in the corner where the
/// window was, as wide as [width]. On Wayland the compositor decides
/// where a window goes and whether it stays on top: GNOME ignores both
/// (KDE has "Keep above" in the window's menu), and it is only smaller
/// there. Dragging it works everywhere.
class DesktopFloatingWindow implements FloatingWindow {
  static const width = 480.0;

  /// Off the screen's edges.
  static const margin = 24.0;

  final _events = StreamController<FloatingEvent>.broadcast();
  Window? get _window => WindowManager.instance.getCurrent();

  /// Where the window was, to go back there.
  Rect? _before;
  bool _wasMaximized = false;

  @override
  Future<bool> supported() async => true;

  @override
  bool get leavesFullScreen => true;

  @override
  Future<bool> enter(double aspectRatio) async {
    final window = _window;
    if (window == null || _before != null) return false;
    // GTK leaves full screen later, then puts back the size it had: the
    // new size would be lost.
    for (var i = 0; i < 20 && window.isFullScreen; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 50));
    }
    _wasMaximized = window.isMaximized;
    if (_wasMaximized) window.unmaximize();
    final before = window.bounds.toRect();
    _before = before;
    // A picture wider than the cinema's, or taller than a phone's: a
    // stream that says something odd.
    final ratio = aspectRatio.clamp(0.5, 2.4);
    final size = Size(width, width / ratio);
    window
      ..titleBarStyle = TitleBarStyle.hidden
      ..isAlwaysOnTop = true
      ..bounds = Rect.fromLTWH(
        math.max(before.left, before.right - size.width - margin),
        math.max(before.top, before.bottom - size.height - margin),
        size.width,
        size.height,
      ).toNative();
    _events.add(FloatingEvent.entered);
    return true;
  }

  @override
  Future<void> leave() async {
    final before = _before;
    final window = _window;
    if (before == null || window == null) return;
    _before = null;
    window
      ..isAlwaysOnTop = false
      ..titleBarStyle = TitleBarStyle.normal
      ..bounds = before.toNative();
    if (_wasMaximized) window.maximize();
    _events.add(FloatingEvent.expanded);
  }

  // The desktop has no Home to float from by itself, nor buttons of its own.
  @override
  void offer(FloatingOffer? offer) {}

  @override
  void startDragging() => _window?.startDragging();

  @override
  Stream<FloatingEvent> get events => _events.stream;

  @override
  void dispose() => unawaited(_events.close());
}

/// Android's picture in picture, driven by MainActivity.kt.
class AndroidFloatingWindow implements FloatingWindow {
  AndroidFloatingWindow() {
    _channel.setMethodCallHandler(_onCall);
  }

  static const _channel = MethodChannel('lighthouse/floating');

  final _events = StreamController<FloatingEvent>.broadcast();

  Future<Object?> _onCall(MethodCall call) async {
    if (call.method != 'event') return null;
    final event = FloatingEvent.values
        .where((e) => e.name == call.arguments)
        .firstOrNull;
    if (event != null) _events.add(event);
    return null;
  }

  @override
  Future<bool> supported() => _ask<bool>('supported').then((v) => v ?? false);

  @override
  bool get leavesFullScreen => false;

  @override
  Future<bool> enter(double aspectRatio) =>
      _ask<bool>('enter', aspectRatio).then((v) => v ?? false);

  @override
  Future<void> leave() => _ask<void>('leave');

  @override
  void offer(FloatingOffer? offer) => unawaited(
    _ask<void>(
      'offer',
      offer == null
          ? null
          : {
              'aspectRatio': offer.aspectRatio,
              'playing': offer.playing,
              'play': offer.play,
              'pause': offer.pause,
              'back10': offer.back10,
              'forward10': offer.forward10,
            },
    ),
  );

  @override
  void startDragging() {}

  @override
  Stream<FloatingEvent> get events => _events.stream;

  /// A failure only costs the floating window: said in the log.
  Future<T?> _ask<T>(String method, [Object? arguments]) async {
    try {
      return await _channel.invokeMethod<T>(method, arguments);
    } on PlatformException catch (e) {
      log.warning('floating', 'cannot $method', e);
      return null;
    } on MissingPluginException catch (e) {
      log.warning('floating', 'cannot $method', e);
      return null;
    }
  }

  @override
  void dispose() {
    _channel.setMethodCallHandler(null);
    unawaited(_events.close());
  }
}
