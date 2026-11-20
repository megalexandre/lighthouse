import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../step/world.dart';

/// Run by the generated tests around each scenario of this folder.
abstract class Hooks {
  const Hooks._();

  static FutureOr<void> beforeEach(String title, [List<String>? tags]) {}

  static FutureOr<void> beforeAll() {}

  /// Takes the app down after every scenario, failed ones included, so its
  /// timers (the player's controls hiding, its progress reports) end with
  /// the scenario.
  static Future<void> afterEach(
    String title,
    bool success, [
    List<String>? tags,
  ]) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
  }

  static FutureOr<void> afterAll() {}
}
