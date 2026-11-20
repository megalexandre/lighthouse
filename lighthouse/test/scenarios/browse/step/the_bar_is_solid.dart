import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

/// Usage: Then the bar is solid
Future<void> theBarIsSolid(WidgetTester tester) async {
  expect(
    tester.widget<FloatingTopBar>(find.byType(FloatingTopBar)).solid,
    isTrue,
  );
}
