import 'dart:math';

import 'storage.dart';

const deviceIdKey = 'device_id';

/// The id this installation sends as `DeviceId`. The server ties sessions
/// and tokens to it, so it is created once and then reused forever.
Future<String> loadOrCreateDeviceId(
  KeyValueStore store, {
  Random? random,
}) async {
  final stored = await store.read(deviceIdKey);
  if (stored != null && stored.isNotEmpty) return stored;

  final rng = random ?? Random.secure();
  final id = List.generate(
    16,
    (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
  await store.write(deviceIdKey, id);
  return id;
}
