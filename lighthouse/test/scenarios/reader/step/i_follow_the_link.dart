import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I follow the link
///
/// It opens the first page, across its width.
Future<void> iFollowTheLink(WidgetTester tester) async {
  final page = tester.getRect(find.byKey(ReaderScreen.pages));
  await tester.tapAt(page.topLeft + Offset(page.width * 0.5, 70));
  await tester.pumpAndSettle();
}
