import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';

import '../../../support/fakes.dart';
import 'world.dart';

/// Usage: Given the book cannot be downloaded
Future<void> theBookCannotBeDownloaded(WidgetTester tester) async {
  app.books.failures['file'] = const ServerUnreachable(testUrl);
}
