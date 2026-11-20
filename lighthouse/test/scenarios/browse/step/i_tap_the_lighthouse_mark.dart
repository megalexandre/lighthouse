import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

/// Usage: When I tap the Lighthouse mark
///
/// At the start of the bar.
Future<void> iTapTheLighthouseMark(WidgetTester tester) async {
  await tester.tap(find.byKey(FloatingTopBar.mark));
  await tester.pumpAndSettle();
}
