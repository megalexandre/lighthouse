import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/device_id.dart';
import 'package:lighthouse/core/storage.dart';

void main() {
  test('is created once, stored, and reused', () async {
    final store = MemoryKeyValueStore();
    final first = await loadOrCreateDeviceId(store);
    expect(first, matches(RegExp(r'^[0-9a-f]{32}$')));
    expect(store.values[deviceIdKey], first);

    expect(await loadOrCreateDeviceId(store), first);
  });

  test('two installations get different ids', () async {
    final a = await loadOrCreateDeviceId(
      MemoryKeyValueStore(),
      random: Random(1),
    );
    final b = await loadOrCreateDeviceId(
      MemoryKeyValueStore(),
      random: Random(2),
    );
    expect(a, isNot(b));
  });
}
