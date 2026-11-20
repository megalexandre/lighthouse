import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the {'light'} mode was chosen
Future<void> theModeWasChosen(WidgetTester tester, String mode) async {
  app.appFiles.values['appearance'] = '{"mode":"$mode"}';
}
