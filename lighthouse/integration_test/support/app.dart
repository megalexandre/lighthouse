import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/app.dart';
import 'package:lighthouse/core/storage.dart';
import 'package:lighthouse/core/theme/appearance.dart';
import 'package:lighthouse/core/theme/theme_catalog.dart';
import 'package:lighthouse/core/window.dart';
import 'package:lighthouse/features/player/data/player_engine.dart';
import 'package:lighthouse/features/reader/data/book_repository.dart';
import 'package:lighthouse/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

/// Stands in for the window: Xvfb has no window manager to go full
/// screen with.
class TestWindow implements AppWindow {
  @override
  bool isFullScreen = false;
}

final window = TestWindow();

/// Starts the app (or restarts it: new providers, same [store]). Only the
/// keyring is swapped for [store] (and the reader's files for
/// [readerStore]), so tests never touch the desktop's keyring (and CI has
/// none) or data, and mpv runs without sound or hardware decoding (CI has
/// neither). In English, the tests' language, unless [asInstalled]: then
/// in the app's default language.
Future<void> launch(
  WidgetTester tester,
  MemoryKeyValueStore store, {
  MemoryKeyValueStore? readerStore,
  String theme = 'builtin:lanterna.json',
  bool asInstalled = false,
}) async {
  _simulateTextInput(tester);
  final themes = await loadBuiltInThemes(rootBundle);
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      retry: noAutomaticRetry,
      overrides: [
        // The tests' texts are English.
        if (!asInstalled)
          defaultLanguageProvider.overrideWithValue(AppLanguage.en),
        keyValueStoreProvider.overrideWithValue(store),
        readerStoreProvider.overrideWithValue(
          readerStore ?? MemoryKeyValueStore(),
        ),
        // The app's own files (the appearance) and themes folder: kept
        // off the desktop's.
        // Lanterna's plain layout for the flows (Prime's is tested in
        // test/features/home/prime_layout_test.dart); [theme] to change.
        appFilesStoreProvider.overrideWithValue(
          MemoryKeyValueStore()
            ..values['appearance'] = '{"chosenTheme":"$theme"}',
        ),
        builtInThemesProvider.overrideWithValue(themes),
        userThemeSourceProvider.overrideWithValue(const NoUserThemes()),
        playerOptionsProvider.overrideWithValue(
          const PlayerOptions(hardwareDecoding: false, audio: false),
        ),
        appWindowProvider.overrideWithValue(window),
      ],
      child: const JellyfinApp(),
    ),
  );
}

/// Text input goes through the test's simulated platform input, set up
/// before any screen exists: a field that takes focus by itself (the
/// server address, the search box) opens its input connection at once,
/// and one opened on the real platform input never sees typed text.
void _simulateTextInput(WidgetTester tester) {
  if (tester.testTextInput.isRegistered) return;
  tester.testTextInput.register();
  addTearDown(tester.testTextInput.unregister);
}

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
  await settleRoute(tester);
}

/// Gives a route transition time to finish (a tap's, or one the app
/// starts by itself, like playing the next episode).
Future<void> settleRoute(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

/// [finder], only inside the screen of type [screen]. While a route
/// transition runs, the screen underneath is still on stage, so a bare
/// finder can match it too.
Finder onScreen(Type screen, Finder finder) =>
    find.descendant(of: find.byType(screen), matching: finder);

/// Pumps until [condition] holds (real time: playback, HTTP). [poll], if
/// given, runs before each check (e.g. to read an mpv property).
Future<void> waitUntil(
  WidgetTester tester,
  bool Function() condition, {
  required String reason,
  Duration timeout = const Duration(seconds: 20),
  Future<void> Function()? poll,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (true) {
    await poll?.call();
    if (condition()) return;
    if (DateTime.now().isAfter(deadline)) fail('timed out: $reason');
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// Types [text] into [field] as a user would: focus it, then send the
/// text through the (simulated) platform text input, so onChanged fires
/// and filters react. Works under `flutter test` and `flutter drive`
/// (profile), where enterText alone does not reach the field.
///
/// Focus moves a frame or more after the tap; text sent before that goes
/// to the field that still had it. So it checks the text landed in
/// [field], and tries again (up to 5 times) when it did not.
Future<void> typeInto(WidgetTester tester, Finder field, String text) async {
  _simulateTextInput(tester);
  final editable = find.descendant(
    of: field,
    matching: find.byType(EditableText),
  );
  for (var attempt = 0; attempt < 5; attempt++) {
    await tester.tap(field);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.showKeyboard(field);
    await tester.pump();
    tester.testTextInput.enterText(text);
    await tester.pump();
    final typed = tester.widget<EditableText>(editable.first).controller.text;
    if (typed == text) return;
    await tester.pump(const Duration(milliseconds: 200));
  }
  fail('could not type "$text" into $field');
}

/// The physical keys of the logical keys tests press. Under `flutter
/// drive` (profile) the key simulator cannot look them up itself.
final _physical = {
  LogicalKeyboardKey.pageDown: PhysicalKeyboardKey.pageDown,
  LogicalKeyboardKey.pageUp: PhysicalKeyboardKey.pageUp,
  LogicalKeyboardKey.arrowLeft: PhysicalKeyboardKey.arrowLeft,
  LogicalKeyboardKey.arrowRight: PhysicalKeyboardKey.arrowRight,
  LogicalKeyboardKey.space: PhysicalKeyboardKey.space,
  LogicalKeyboardKey.escape: PhysicalKeyboardKey.escape,
};

/// Presses and releases [key], as a keyboard would.
Future<void> pressKey(WidgetTester tester, LogicalKeyboardKey key) async {
  final physical = _physical[key];
  if (physical == null) throw ArgumentError('add $key to _physical');
  await tester.sendKeyEvent(key, physicalKey: physical);
}
