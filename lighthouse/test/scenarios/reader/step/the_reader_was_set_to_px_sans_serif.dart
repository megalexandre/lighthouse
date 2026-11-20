import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the reader was set to {'sepia'}, {24} px, sans serif
///
/// Its preferences, stored on this device by an earlier run.
Future<void> theReaderWasSetToPxSansSerif(
  WidgetTester tester,
  String theme,
  num size,
) async {
  app.readerStore.values['preferences'] =
      '{"theme":"$theme","fontSize":$size,"sansSerif":true}';
}
