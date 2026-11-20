import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';
import 'package:lighthouse/features/library/presentation/library_screen.dart';

import 'world.dart';

/// Usage: Then the {'Movies'} tab is on
///
/// Its library open under the bar.
Future<void> theTabIsOn(WidgetTester tester, String library) async {
  expect(find.byType(LibraryScreen), findsOneWidget);
  expect(
    tester.widget<FloatingTopBar>(find.byType(FloatingTopBar)).activeView,
    itemNamed(library).id,
  );
}
