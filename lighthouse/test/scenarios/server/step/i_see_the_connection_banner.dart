import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/server/presentation/connection_banner.dart';

/// Usage: Then I see the connection banner
///
/// Saying the server cannot be reached, and that the app keeps trying.
Future<void> iSeeTheConnectionBanner(WidgetTester tester) async {
  expect(find.byKey(ConnectionBanner.banner), findsOneWidget);
  expect(find.text("Can't reach Test Server. Trying again…"), findsOneWidget);
}
