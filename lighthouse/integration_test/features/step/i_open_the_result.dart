import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/search/presentation/search_screen.dart';

import '../../support/app.dart';
import 'world.dart' as world;

/// Usage: And I open the result {'Test Movie (2020)'}
Future<void> iOpenTheResult(WidgetTester tester, String name) async {
  final result = onScreen(SearchScreen, find.text(name));
  await waitFor(tester, result);
  await tapOn(tester, result);
  world.item = name;
}
