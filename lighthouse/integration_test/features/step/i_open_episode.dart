import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';

import '../../support/app.dart';

/// Usage: When I open episode {2}
///
/// Its line on the season's page ("2. ...").
Future<void> iOpenEpisode(WidgetTester tester, num number) async {
  await tapOn(tester, onScreen(ItemScreen, find.textContaining('$number. ')));
}
