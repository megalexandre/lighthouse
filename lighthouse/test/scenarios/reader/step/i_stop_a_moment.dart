import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/application/reader_controller.dart';

/// Usage: When I stop a moment
///
/// Long enough for the reader to save the place.
Future<void> iStopAMoment(WidgetTester tester) async {
  await tester.pump(ReaderController.saveDelay);
  await tester.pumpAndSettle();
}
