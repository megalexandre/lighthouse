import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

/// Usage: And the bar is see-through
///
/// Over the carousel.
Future<void> theBarIsSeethrough(WidgetTester tester) async {
  expect(
    tester.widget<FloatingTopBar>(find.byType(FloatingTopBar)).solid,
    isFalse,
  );
}
