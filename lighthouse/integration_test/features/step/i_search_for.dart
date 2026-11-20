import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';
import 'package:lighthouse/features/search/presentation/search_screen.dart';

import '../../support/app.dart';

/// Usage: When I search for {'test mov'}
///
/// From home's search button.
Future<void> iSearchFor(WidgetTester tester, String text) async {
  await waitFor(tester, find.byKey(HomeScreen.searchButton));
  await tapOn(tester, find.byKey(HomeScreen.searchButton));
  await waitFor(tester, find.byKey(SearchScreen.field));
  await typeInto(tester, find.byKey(SearchScreen.field), text);
}
