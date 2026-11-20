import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/application/reader_preferences.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: Then I can pick the {'sepia'} theme
Future<void> iCanPickTheTheme(WidgetTester tester, String theme) async {
  expect(
    find.byKey(ReaderScreen.themeChoice(ReaderTheme.values.byName(theme))),
    findsOneWidget,
  );
}
