import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I drag the page bar to the end
///
/// The slider at the bottom of the reader.
Future<void> iDragThePageBarToTheEnd(WidgetTester tester) async {
  final bar = tester.getRect(find.byKey(ReaderScreen.slider));
  await tester.dragFrom(bar.center, Offset(bar.width, 0));
  await tester.pumpAndSettle();
}
