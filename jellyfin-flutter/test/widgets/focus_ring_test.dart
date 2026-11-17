import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/core/theme/design_tokens.dart';
import 'package:jellyfin_flutter/core/theme/theme_builder.dart';
import 'package:jellyfin_flutter/widgets/app_button.dart';
import 'package:jellyfin_flutter/widgets/focus_ring.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final theme = buildTheme(
    DesignTokens.parse(File('assets/themes/lanterna.json').readAsStringSync()),
    Brightness.dark,
  );

  Future<void> pumpButtons(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Row(
          children: [
            AppButton(label: 'Play', onPressed: () {}),
            AppButton.secondary(label: 'Start over', onPressed: () {}),
          ],
        ),
      ),
    ),
  );

  /// Whether the button labelled [label] draws its ring (the painter of
  /// the ring's own CustomPaint, right inside its FocusRing).
  bool ringOn(WidgetTester tester, String label) =>
      tester
          .widget<CustomPaint>(
            find
                .descendant(
                  of: find.ancestor(
                    of: find.text(label),
                    matching: find.byType(FocusRing),
                  ),
                  matching: find.byType(CustomPaint),
                )
                .first,
          )
          .foregroundPainter !=
      null;

  testWidgets('the ring follows the keyboard focus', (tester) async {
    await pumpButtons(tester);
    expect(ringOn(tester, 'Play'), isFalse);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(ringOn(tester, 'Play'), isTrue);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(ringOn(tester, 'Play'), isFalse);
    expect(ringOn(tester, 'Start over'), isTrue);
  });

  testWidgets('a click focuses without a ring', (tester) async {
    await pumpButtons(tester);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: tester.getCenter(find.text('Play')));
    await mouse.down(tester.getCenter(find.text('Play')));
    await mouse.up();
    await tester.pump();
    expect(ringOn(tester, 'Play'), isFalse);
    expect(find.byType(FocusRing), findsNWidgets(2));
  });
}
