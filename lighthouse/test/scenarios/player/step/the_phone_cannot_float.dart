import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the phone cannot float
///
/// It has no picture in picture.
Future<void> thePhoneCannotFloat(WidgetTester tester) async {
  app.floating.canFloat = false;
}
