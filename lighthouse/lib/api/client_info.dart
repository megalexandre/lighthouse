import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/config.dart';
import '../core/device_id.dart';
import '../core/log.dart';
import '../core/storage.dart';

/// Who is calling, as the server sees it in its Authorization header.
class ClientInfo {
  const ClientInfo({
    required this.deviceId,
    required this.device,
    this.client = clientName,
    this.version = appVersion,
  });

  final String client;
  final String device;
  final String deviceId;
  final String version;

  /// `MediaBrowser Client="…", Device="…", DeviceId="…", Version="…"[, Token="…"]`.
  /// The server URL-decodes every value, so each one is encoded: a device
  /// name with a comma or a quote would otherwise break the header.
  String authorizationHeader({String? token}) {
    final parts = {
      'Client': client,
      'Device': device,
      'DeviceId': deviceId,
      'Version': version,
      'Token': ?token,
    };
    return 'MediaBrowser ${parts.entries.map((e) => '${e.key}="${Uri.encodeComponent(e.value)}"').join(', ')}';
  }
}

final clientInfoProvider = FutureProvider<ClientInfo>((ref) async {
  final deviceId = await loadOrCreateDeviceId(ref.watch(keyValueStoreProvider));
  return ClientInfo(deviceId: deviceId, device: await _deviceName());
});

/// The name the server lists this device under. On Android the hostname is
/// always "localhost": the activity gives the phone's name instead
/// (MainActivity.kt).
Future<String> _deviceName() async {
  if (!Platform.isAndroid) return Platform.localHostname;
  try {
    final name = await const MethodChannel('lighthouse/device')
        .invokeMethod<String>('name');
    if (name != null && name.isNotEmpty) return name;
  } on PlatformException catch (e) {
    log.warning('device', 'cannot read the device name', e.message);
  }
  return 'Android';
}
