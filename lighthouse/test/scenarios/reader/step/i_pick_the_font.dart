import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: And I pick the font {'Literata'}
///
/// From the menu in the open display settings.
Future<void> iPickTheFont(WidgetTester tester, String font) async {
  await tester.tap(find.byKey(ReaderScreen.fontMenu));
  await tester.pumpAndSettle();
  await tester.tap(find.text(font).last);
  await tester.pumpAndSettle();
}
