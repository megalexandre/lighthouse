import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I go back from the link
///
/// The "Back to page N" button.
Future<void> iGoBackFromTheLink(WidgetTester tester) async {
  await tester.tap(find.byKey(ReaderScreen.linkBack));
  await tester.pumpAndSettle();
}
