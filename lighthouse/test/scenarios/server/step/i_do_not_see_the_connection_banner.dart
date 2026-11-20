import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/server/presentation/connection_banner.dart';

/// Usage: Then I do not see the connection banner
Future<void> iDoNotSeeTheConnectionBanner(WidgetTester tester) async {
  expect(find.byKey(ConnectionBanner.banner), findsNothing);
}
