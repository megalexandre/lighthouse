import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';
import 'world.dart';

/// Usage: Given the app runs on a {'phone'}
///
/// One of [TestDevice]: 'phone', 'phone on its side', 'tablet on its side'.
/// As an Android device, with touch, in Prime (the phone layout's only
/// theme); the app opens on it on the first `When`.
Future<void> theAppRunsOnA(WidgetTester tester, String device) async {
  app.runOn(TestDevice.called(device));
}
