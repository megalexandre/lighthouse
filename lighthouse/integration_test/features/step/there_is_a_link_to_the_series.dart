import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';

import '../../support/app.dart';

/// Usage: And there is a link to the series
Future<void> thereIsALinkToTheSeries(WidgetTester tester) async {
  await waitFor(tester, find.byKey(ItemScreen.seriesLink));
}
