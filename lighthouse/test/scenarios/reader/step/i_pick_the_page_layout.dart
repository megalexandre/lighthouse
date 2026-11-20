import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/application/reader_preferences.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

import 'i_close_the_display_settings.dart';

/// Usage: When I pick the {'double'} page layout
///
/// In the display settings, which close after (a [PageLayout] name).
Future<void> iPickThePageLayout(WidgetTester tester, String layout) async {
  await tester.tap(find.byKey(ReaderScreen.displayButton));
  await tester.pumpAndSettle();
  final choice = find.byKey(
    ReaderScreen.layoutChoice(PageLayout.values.byName(layout)),
  );
  await tester.ensureVisible(choice);
  await tester.pumpAndSettle();
  await tester.tap(choice);
  await tester.pumpAndSettle();
  await iCloseTheDisplaySettings(tester);
}
