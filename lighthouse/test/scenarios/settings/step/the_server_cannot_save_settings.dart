import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';

import '../../../support/fakes.dart';
import 'world.dart';

/// Usage: Given the server cannot save settings
Future<void> theServerCannotSaveSettings(WidgetTester tester) async {
  app.settings.failures['update'] = const ServerUnreachable(testUrl);
}
