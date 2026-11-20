import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

import '../../support/app.dart';

/// Usage: Then I am home
Future<void> iAmHome(WidgetTester tester) async {
  await waitFor(tester, find.byKey(HomeScreen.viewsRow));
}
