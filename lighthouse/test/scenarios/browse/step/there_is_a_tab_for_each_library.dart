import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

import '../../../support/fakes.dart';

/// Usage: Then there is a tab for each library
///
/// After Home's, in the bar over the screen.
Future<void> thereIsATabForEachLibrary(WidgetTester tester) async {
  expect(find.byKey(FloatingTopBar.homeTab), findsOneWidget);
  for (final view in TestItems.views) {
    expect(find.byKey(FloatingTopBar.tab(view.id)), findsOneWidget);
  }
}
