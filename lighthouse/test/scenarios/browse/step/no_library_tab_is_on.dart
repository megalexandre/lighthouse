import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

/// Usage: And no library tab is on
Future<void> noLibraryTabIsOn(WidgetTester tester) async {
  expect(
    tester.widget<FloatingTopBar>(find.byType(FloatingTopBar)).activeView,
    isNull,
  );
}
