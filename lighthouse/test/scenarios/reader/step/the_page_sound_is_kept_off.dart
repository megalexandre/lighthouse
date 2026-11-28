import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the page sound is kept off
///
/// In the reader's preferences on this device.
Future<void> thePageSoundIsKeptOff(WidgetTester tester) async {
  final stored = jsonDecode(
    app.readerStore.values['preferences']!,
  ) as Map<String, dynamic>;
  expect(stored['pageSound'], isFalse);
}
