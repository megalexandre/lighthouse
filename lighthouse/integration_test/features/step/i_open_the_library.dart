import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/library/presentation/library_screen.dart';

import '../../support/app.dart';

/// Usage: When I open the {'Movies'} library
///
/// Its card in home's first row.
Future<void> iOpenTheLibrary(WidgetTester tester, String name) async {
  final view = find.descendant(
    of: find.byKey(HomeScreen.viewsRow),
    matching: find.text(name),
  );
  await waitFor(tester, view);
  await tapOn(tester, view);
  await waitFor(tester, find.byType(LibraryScreen));
}
