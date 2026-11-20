import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

/// Usage: Then the top bar shows only the mark
///
/// No tabs, search or profile: they are in the navigation.
Future<void> theTopBarShowsOnlyTheMark(WidgetTester tester) async {
  expect(find.byKey(FloatingTopBar.mark), findsOneWidget);
  expect(find.byKey(FloatingTopBar.homeTab), findsNothing);
  expect(find.byKey(FloatingTopBar.searchButton), findsNothing);
  expect(find.byKey(FloatingTopBar.profileButton), findsNothing);
}
