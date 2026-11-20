import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

/// Usage: Then there is no bar of tabs
Future<void> thereIsNoBarOfTabs(WidgetTester tester) async {
  expect(find.byType(FloatingTopBar), findsNothing);
}
