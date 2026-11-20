import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: And the book is still open
Future<void> theBookIsStillOpen(WidgetTester tester) async {
  expect(find.byType(ReaderScreen), findsOneWidget);
}
