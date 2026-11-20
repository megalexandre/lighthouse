import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: Then the reader is open
Future<void> theReaderIsOpen(WidgetTester tester) async {
  expect(find.byType(ReaderScreen), findsOneWidget);
}
