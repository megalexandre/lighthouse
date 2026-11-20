import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the theme is {'Prime'}
///
/// One of the built-in themes; the others' scenarios use Lanterna.
Future<void> theThemeIs(WidgetTester tester, String name) async {
  app.appFiles.values['appearance'] =
      '{"chosenTheme":"builtin:${name.toLowerCase()}.json"}';
}
