import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'log.dart';

/// The phone's media volume and the brightness of the app's window, which
/// the player's swipes change. Levels go from 0 to 1.
abstract interface class DeviceLevels {
  /// The media volume, the one the phone's keys change. Null where the app
  /// has no say in it (a desktop: the player's own volume instead).
  Future<double?> volume();
  Future<void> setVolume(double level);

  /// The window's brightness, or the screen's while the window sets none.
  /// Null where it cannot be changed (a desktop window).
  Future<double?> brightness();
  Future<void> setBrightness(double level);

  /// The window follows the screen's own brightness again.
  Future<void> resetBrightness();
}

final deviceLevelsProvider = Provider<DeviceLevels>(
  (_) => Platform.isAndroid ? AndroidDeviceLevels() : const NoDeviceLevels(),
);

/// A desktop: neither is the app's to change.
class NoDeviceLevels implements DeviceLevels {
  const NoDeviceLevels();

  @override
  Future<double?> volume() async => null;
  @override
  Future<void> setVolume(double level) async {}
  @override
  Future<double?> brightness() async => null;
  @override
  Future<void> setBrightness(double level) async {}
  @override
  Future<void> resetBrightness() async {}
}

/// Through MainActivity.kt ("lighthouse/device"). A failure is logged and
/// the swipe does nothing, rather than breaking the player.
class AndroidDeviceLevels implements DeviceLevels {
  static const _channel = MethodChannel('lighthouse/device');

  Future<T?> _call<T>(String method, [Object? argument]) async {
    try {
      return await _channel.invokeMethod<T>(method, argument);
    } on PlatformException catch (e) {
      log.warning('device', '$method failed', e.message);
      return null;
    }
  }

  @override
  Future<double?> volume() => _call<double>('volume');
  @override
  Future<void> setVolume(double level) => _call<void>('setVolume', level);
  @override
  Future<double?> brightness() => _call<double>('brightness');
  @override
  Future<void> setBrightness(double level) =>
      _call<void>('setBrightness', level);
  @override
  Future<void> resetBrightness() => _call<void>('setBrightness');
}
