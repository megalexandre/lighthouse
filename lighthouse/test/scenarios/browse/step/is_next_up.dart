import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And {'Episode 2'} is next up
Future<void> isNextUp(WidgetTester tester, String name) async {
  app.library.nextUpItems = [itemNamed(name)];
}
