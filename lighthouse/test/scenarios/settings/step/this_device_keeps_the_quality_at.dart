import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then this device keeps the quality at {'2 Mbps'}
///
/// Not the server: Jellyfin keeps no such setting per user. 'Maximum' is
/// no limit.
Future<void> thisDeviceKeepsTheQualityAt(
  WidgetTester tester,
  String quality,
) async {
  final mbps = int.tryParse(quality.split(' ').first);
  expect(app.settings.bitrate, mbps == null ? null : mbps * 1000000);
}
