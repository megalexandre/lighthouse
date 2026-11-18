import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the server keeps page {3} of {'Test Comic'}
///
/// On 12.4's scale for a comic or a PDF: 10000 ticks a page, from 0.
Future<void> theServerKeepsPageOf(
  WidgetTester tester,
  num page,
  String name,
) async {
  final data = await userDataOf(name);
  expect(data['PlaybackPositionTicks'], (page.toInt() - 1) * 10000);
}
