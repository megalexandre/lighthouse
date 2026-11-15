import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

/// The app's window, behind an interface so tests (and CI, which may have
/// no window manager) can use a fake.
abstract interface class AppWindow {
  bool get isFullScreen;
  set isFullScreen(bool value);
}

final appWindowProvider = Provider<AppWindow>((_) => NativeAppWindow());

/// The real window (window_manager 0.7, synchronous native API).
class NativeAppWindow implements AppWindow {
  Window? get _window => WindowManager.instance.getCurrent();

  @override
  bool get isFullScreen => _window?.isFullScreen ?? false;

  @override
  set isFullScreen(bool value) => _window?.isFullScreen = value;
}
