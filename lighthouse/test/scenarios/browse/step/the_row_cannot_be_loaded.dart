import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// The fake library's method behind each of home's rows.
const _methods = {
  'Latest in Movies': 'latest',
  'Continue watching': 'resume',
  'Next up': 'nextUp',
  'Continue reading': 'resumeBooks',
};

/// Usage: Given the {'Next up'} row cannot be loaded
///
/// As if the server were gone when home asks for it ('Latest in Movies':
/// every library's latest).
Future<void> theRowCannotBeLoaded(WidgetTester tester, String row) async {
  app.library.failures[_methods[row]!] = unreachable;
}
