import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Then the file manager opens {'/themes'}
///
/// The desktop's, asked by the app (xdg-open on Linux).
Future<void> theFileManagerOpens(WidgetTester tester, String folder) async {
  expect(app.openedFolders, [folder]);
}
