import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';

import 'world.dart';

/// Usage: And the server stops answering
///
/// It can give no new stream: it answers 503.
Future<void> theServerStopsAnswering(WidgetTester tester) async {
  app.playback.failures['prepare'] = const ServerError(
    'HTTP 503',
    statusCode: 503,
  );
}
