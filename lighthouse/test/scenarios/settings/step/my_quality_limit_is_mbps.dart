import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And my quality limit is {4} Mbps
Future<void> myQualityLimitIsMbps(WidgetTester tester, num mbps) async {
  app.settings.bitrate = (mbps * 1000000).toInt();
}
