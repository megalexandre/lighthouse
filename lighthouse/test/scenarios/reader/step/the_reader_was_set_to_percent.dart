import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: Given the reader was set to {'sepia'}, {135} percent, {'literata'}
///
/// Its preferences, stored on this device by an earlier run: the theme,
/// the type size and the font (a [ReaderFont] name).
Future<void> theReaderWasSetToPercent(
  WidgetTester tester,
  String theme,
  num percent,
  String font,
) async {
  storeReaderPreferences({'theme': theme, 'fontScale': percent, 'font': font});
}
