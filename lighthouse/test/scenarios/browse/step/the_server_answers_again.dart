import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When the server answers again
///
/// Whatever could not be loaded can be now.
Future<void> theServerAnswersAgain(WidgetTester tester) async {
  app.library.failures.clear();
}
