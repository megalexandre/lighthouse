import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/player/presentation/player_screen.dart';
import 'package:jellyfin_flutter/features/reader/presentation/reader_screen.dart';
import 'package:jellyfin_test_server/jellyfin_test_server.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';

import '../../support/app.dart';
import '../step/world.dart';

/// Run by the generated tests around each scenario of this folder.
abstract class Hooks {
  const Hooks._();

  /// libmpv loaded, and the test server set up (once per process).
  static Future<void> beforeAll() async {
    MediaKit.ensureInitialized();
    server = await TestServer.start();
  }

  static FutureOr<void> beforeEach(String title, [List<String>? tags]) {}

  /// After a passing scenario, leaves the player or the reader the way a
  /// user would, so their last report reaches the server; then takes the
  /// app down, so nothing of it runs into the next scenario.
  static Future<void> afterEach(
    String title,
    bool success, [
    List<String>? tags,
  ]) async {
    if (success) {
      for (final key in [PlayerScreen.backButton, ReaderScreen.backButton]) {
        final back = find.byKey(key);
        if (back.evaluate().isEmpty) continue;
        await tapOn(tester, back.first);
        await waitUntil(
          tester,
          () => back.evaluate().isEmpty,
          reason: 'leaving with $key',
        );
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  }

  static FutureOr<void> afterAll() {}
}
