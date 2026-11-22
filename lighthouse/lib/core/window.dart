import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:window_manager/window_manager.dart';

import 'log.dart';

/// The app's window, behind an interface so tests (and CI, which may have
/// no window manager) can use a fake.
abstract interface class AppWindow {
  bool get isFullScreen;
  set isFullScreen(bool value);

  /// Held sideways, whichever way the phone is (a video playing). Nothing
  /// on a desktop.
  bool get isLandscape;
  set isLandscape(bool value);

  /// The screen does not turn off by itself (a book open: reading gives no
  /// input for minutes). Nothing on a desktop, which has its own settings
  /// for that. Video needs no help: media_kit_video does it while playing.
  bool get staysOn;
  set staysOn(bool value);
}

final appWindowProvider = Provider<AppWindow>(
  // window_manager is FFI with no Android side.
  (_) => Platform.isAndroid ? ImmersiveAppWindow() : NativeAppWindow(),
);

/// The real window (window_manager 0.7, synchronous native API).
class NativeAppWindow implements AppWindow {
  Window? get _window => WindowManager.instance.getCurrent();

  @override
  bool get isFullScreen => _window?.isFullScreen ?? false;

  @override
  set isFullScreen(bool value) => _window?.isFullScreen = value;

  @override
  bool isLandscape = false;

  @override
  bool staysOn = false;
}

/// A phone's "full screen": the system bars hidden (immersive mode). They
/// come back for a moment on a swipe from the edge, then hide again.
class ImmersiveAppWindow implements AppWindow {
  bool _fullScreen = false;

  @override
  bool get isFullScreen => _fullScreen;

  @override
  set isFullScreen(bool value) {
    _fullScreen = value;
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        value ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      ),
    );
  }

  bool _landscape = false;

  @override
  bool get isLandscape => _landscape;

  @override
  set isLandscape(bool value) {
    _landscape = value;
    unawaited(
      SystemChrome.setPreferredOrientations([
        // Either side; none: back to following the phone.
        if (value) ...[
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      ]),
    );
  }

  bool _staysOn = false;

  @override
  bool get staysOn => _staysOn;

  @override
  set staysOn(bool value) {
    _staysOn = value;
    unawaited(
      WakelockPlus.toggle(enable: value).catchError(
        (Object e) => log.warning('window', 'cannot keep the screen on', e),
      ),
    );
  }
}
