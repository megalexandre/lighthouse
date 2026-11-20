import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'world.dart' as world;

/// Usage: Given the window is {1600} by {1000}
///
/// The window the app opens in: a wide one shows two pages.
Future<void> theWindowIsBy(WidgetTester tester, num width, num height) async {
  world.window = Size(width.toDouble(), height.toDouble());
}
