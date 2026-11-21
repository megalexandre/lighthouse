import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

/// The app's window, behind an interface so tests (and CI, which may have
/// no window manager) can use a fake.
abstract interface class AppWindow {
  bool get isFullScreen;
  set isFullScreen(bool value);
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
}
