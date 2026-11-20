import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And {'Mine'} was chosen
///
/// The theme of that name in the user's folder.
Future<void> wasChosen(WidgetTester tester, String name) async {
  app.appFiles.values['appearance'] =
      '{"chosenTheme":"user:${name.toLowerCase()}.json"}';
}
