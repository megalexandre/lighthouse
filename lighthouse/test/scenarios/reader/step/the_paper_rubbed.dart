import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the paper rubbed {'softly'}
///
/// While the page was dragged: 'softly' never past a third of the loudest,
/// 'loudly' near it.
Future<void> thePaperRubbed(WidgetTester tester, String how) async {
  final rubs = app.pageSounds.rubs;
  expect(rubs, isNotEmpty);
  final loudest = rubs.reduce((a, b) => a > b ? a : b);
  if (how == 'softly') {
    expect(loudest, lessThan(0.34));
  } else {
    expect(loudest, greaterThan(0.8));
  }
}
