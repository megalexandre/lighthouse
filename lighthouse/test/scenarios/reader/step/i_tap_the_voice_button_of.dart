import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I tap the voice button of {'first'}
///
/// Where the play button of a voice note on that word is drawn (at the end
/// of the word, raised), whether there is one or not.
Future<void> iTapTheVoiceButtonOf(WidgetTester tester, String word) async {
  await tester.tapAt(voiceButtonOnPage(tester, word).center);
  await tester.pumpAndSettle();
}
