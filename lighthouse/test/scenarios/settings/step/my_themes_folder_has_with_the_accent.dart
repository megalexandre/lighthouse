import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/theme/theme_catalog.dart';
import 'package:material_ui/material_ui.dart';

import 'world.dart';

/// Usage: Given my themes folder has {'Mine'} with the accent {'#ff8800'}
///
/// Lanterna, renamed and recoloured, as {name}.json (lower case).
Future<void> myThemesFolderHasWithTheAccent(
  WidgetTester tester,
  String name,
  String accent,
) async {
  app.userThemes.files['${name.toLowerCase()}.json'] = lanterna
      .replaceFirst('"name": "Lanterna"', '"name": "$name"')
      .replaceAll('#00a4dc', accent);
  if (find.byType(Scaffold).evaluate().isNotEmpty) {
    // Saved while the app runs: it watches the folder.
    app.userThemes.changed();
    await tester.pump(ThemeCatalogController.settle);
    await tester.pumpAndSettle();
  }
}
