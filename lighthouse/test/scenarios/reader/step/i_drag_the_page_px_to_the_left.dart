import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

/// Usage: When I drag the page {'slowly'} {60} px to the left
///
/// From the right of the page, in steps a sixtieth of a second apart (as
/// a pointer reports): 'slowly' 2 px a step, 'quickly' 40 px. Then lets
/// go: short of the middle the page falls back, past it it turns.
Future<void> iDragThePagePxToTheLeft(
  WidgetTester tester,
  String pace,
  int distance,
) async {
  final area = tester.getRect(find.byKey(ReaderScreen.pages));
  final step = pace == 'slowly' ? 2.0 : 40.0;
  var at = Duration.zero;
  const frame = Duration(microseconds: 16667);
  final gesture = await tester.startGesture(
    Offset(area.left + area.width * 0.9, area.center.dy),
  );
  for (var moved = 0.0; moved < distance; moved += step) {
    at += frame;
    await gesture.moveBy(Offset(-step, 0), timeStamp: at);
    await tester.pump(frame);
  }
  // Still a moment before letting go: no flick.
  at += const Duration(milliseconds: 200);
  await tester.pump(const Duration(milliseconds: 200));
  await gesture.up(timeStamp: at);
  await tester.pumpAndSettle();
}
