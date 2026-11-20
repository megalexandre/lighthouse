import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

import '../../../support/fakes.dart';

/// Usage: Then I see the libraries
///
/// Home's first row, or, in Prime, the bar's tabs.
Future<void> iSeeTheLibraries(WidgetTester tester) async {
  final row = find.byKey(HomeScreen.viewsRow);
  final tab = find.byKey(FloatingTopBar.tab(TestItems.moviesView.id));
  expect(
    row.evaluate().isNotEmpty || tab.evaluate().isNotEmpty,
    isTrue,
    reason: 'neither the libraries row nor their tabs',
  );
}
