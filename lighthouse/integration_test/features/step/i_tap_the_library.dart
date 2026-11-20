import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

import '../../support/app.dart';

/// Usage: When I tap the {'Movies'} library
///
/// Its card in home's first row; the grid may not load.
Future<void> iTapTheLibrary(WidgetTester tester, String name) async {
  await tapOn(
    tester,
    find.descendant(
      of: find.byKey(HomeScreen.viewsRow),
      matching: find.text(name),
    ),
  );
}
