import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And {42} seconds have played
Future<void> secondsHavePlayed(WidgetTester tester, num seconds) async {
  app.engine.advance(Duration(seconds: seconds.toInt()));
  await tester.pump();
}
