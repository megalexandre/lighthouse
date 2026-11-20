import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/item/presentation/item_screen.dart';
import 'package:material_ui/material_ui.dart';

import '../../support/app.dart';

/// Usage: And its poster comes from the server
///
/// An image on the page, not the placeholder.
Future<void> itsPosterComesFromTheServer(WidgetTester tester) async {
  await waitFor(tester, onScreen(ItemScreen, find.byType(Image)));
}
