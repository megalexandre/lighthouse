import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';

import '../../../support/fakes.dart';
import 'world.dart';

/// Usage: Given my settings cannot be loaded
///
/// Those kept on the server; the server is gone when Settings asks.
Future<void> mySettingsCannotBeLoaded(WidgetTester tester) async {
  app.settings.failures['userConfiguration'] = const ServerUnreachable(testUrl);
}
