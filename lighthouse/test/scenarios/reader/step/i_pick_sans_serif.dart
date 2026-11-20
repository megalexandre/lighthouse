import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: And I pick sans serif
///
/// In the open display settings.
Future<void> iPickSansSerif(WidgetTester tester) async {
  await tester.tap(find.byKey(ReaderScreen.typefaceChoice(sans: true)));
  await tester.pumpAndSettle();
}
