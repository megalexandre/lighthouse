import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/app.dart';
import 'package:jellyfin_flutter/core/storage.dart';
import 'package:material_ui/material_ui.dart';

/// Starts the app (or restarts it: new providers, same [store]). Only the
/// keyring is swapped for [store], so tests never touch the desktop's
/// keyring (and CI has none).
Future<void> launch(WidgetTester tester, MemoryKeyValueStore store) =>
    tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        retry: noAutomaticRetry,
        overrides: [keyValueStoreProvider.overrideWithValue(store)],
        child: const JellyfinApp(),
      ),
    );

/// Pumps until [finder] shows up. Requests here are real HTTP, so there
/// is no "settled" moment to wait for.
Future<void> waitFor(WidgetTester tester, Finder finder) async {
  final deadline = DateTime.now().add(const Duration(seconds: 20));
  while (finder.evaluate().isEmpty) {
    if (DateTime.now().isAfter(deadline)) {
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data)
          .whereType<String>()
          .join(' | ');
      fail('timed out waiting for $finder. On screen: $texts');
    }
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Scrolls [finder] into view and taps it, then gives a route transition
/// time to finish: until it does, the screen underneath is still on stage
/// and finders match on both.
Future<void> tapOn(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// [finder], only inside the screen of type [screen]. While a route
/// transition runs, the screen underneath is still on stage, so a bare
/// finder can match it too.
Finder onScreen(Type screen, Finder finder) =>
    find.descendant(of: find.byType(screen), matching: finder);
