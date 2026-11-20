import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/application/reader_preferences.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I pick the {'dark'} theme
///
/// In the display settings.
Future<void> iPickTheTheme(WidgetTester tester, String theme) async {
  await tester.tap(find.byKey(ReaderScreen.displayButton));
  await tester.pumpAndSettle();
  await tester.tap(
    find.byKey(ReaderScreen.themeChoice(ReaderTheme.values.byName(theme))),
  );
  await tester.pumpAndSettle();
}
