import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';

const _keys = {
  'Down': LogicalKeyboardKey.arrowDown,
  'M': LogicalKeyboardKey.keyM,
};

/// Usage: When I press {'Down'} in the player
Future<void> iPressInThePlayer(WidgetTester tester, String key) async {
  await pressKey(tester, _keys[key]!);
  await tester.pump(const Duration(milliseconds: 300));
}
