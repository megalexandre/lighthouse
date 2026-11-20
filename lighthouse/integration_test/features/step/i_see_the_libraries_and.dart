import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

import '../../support/app.dart';

/// Usage: Then I see the libraries {'Movies'}, {'Shows'} and {'Music'}
///
/// In home's first row.
Future<void> iSeeTheLibrariesAnd(
  WidgetTester tester,
  String first,
  String second,
  String third,
) async {
  for (final name in [first, second, third]) {
    await waitFor(
      tester,
      find.descendant(
        of: find.byKey(HomeScreen.viewsRow),
        matching: find.text(name),
      ),
    );
  }
}
