import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';
import 'world.dart';

/// Usage: Given there is something in every row
///
/// A movie to continue watching, an episode next up, a book to continue
/// reading; the latest rows always have something.
Future<void> thereIsSomethingInEveryRow(WidgetTester tester) async {
  app.library
    ..resumeItems = [TestItems.testMovie]
    ..nextUpItems = [TestItems.episodes[1]]
    ..resumeBookItems = [TestItems.testComic];
}
