import 'package:flutter_test/flutter_test.dart';

/// Usage: Given animations are reduced
///
/// As the desktop's accessibility setting asks.
Future<void> animationsAreReduced(WidgetTester tester) async {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}
