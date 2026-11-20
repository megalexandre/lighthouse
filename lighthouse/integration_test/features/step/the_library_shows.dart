import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/library_screen.dart';

import '../../support/app.dart';

/// Usage: Then the library shows {'Test Movie (2020)'}
///
/// Its card in the grid, once loaded.
Future<void> theLibraryShows(WidgetTester tester, String name) async {
  await waitFor(tester, onScreen(LibraryScreen, find.text(name)));
}
