import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';

import '../../../support/fakes.dart';
import 'world.dart';

/// Usage: Given the server cannot be reached
///
/// Searching fails as if it were gone (the screens before search load).
Future<void> theServerCannotBeReached(WidgetTester tester) async {
  app.library.failures['search'] = const ServerUnreachable(testUrl);
}
