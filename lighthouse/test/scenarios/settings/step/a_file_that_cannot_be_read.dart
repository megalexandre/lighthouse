import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And a file {'broken.json'} that cannot be read
Future<void> aFileThatCannotBeRead(WidgetTester tester, String name) async {
  app.userThemes.files[name] = '{';
}
