import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/theme/design_tokens.dart';
import 'package:lighthouse/core/theme/theme_builder.dart';
import 'package:lighthouse/l10n/l10n.dart';
import 'package:lighthouse/widgets/loading_ring.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final theme = buildTheme(
    DesignTokens.parse(File('assets/themes/lanterna.json').readAsStringSync()),
    Brightness.dark,
  );

  Widget app(Widget child, {bool still = false}) => MaterialApp(
    theme: theme,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: still),
      child: child!,
    ),
    home: Scaffold(body: Center(child: child)),
  );

  CustomPainter painter(WidgetTester tester) => tester
      .widget<CustomPaint>(
        find.descendant(
          of: find.byType(LoadingRing),
          matching: find.byType(CustomPaint),
        ),
      )
      .painter!;

  /// Whether the ring looks different a quarter of a turn later.
  Future<bool> moves(WidgetTester tester) async {
    final before = painter(tester);
    await tester.pump(LoadingRing.period ~/ 4);
    return painter(tester).shouldRepaint(before);
  }

  testWidgets('loading, the arc goes round, and says so', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(app(const LoadingRing()));
    expect(await moves(tester), isTrue);
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('with animations off, the arc stands still', (tester) async {
    await tester.pumpWidget(app(const LoadingRing(), still: true));
    expect(await moves(tester), isFalse);
  });

  testWidgets('with a value, a progress ring that keeps still', (tester) async {
    await tester.pumpWidget(app(const LoadingRing(value: 0.5, onMedia: true)));
    expect(await moves(tester), isFalse);
    expect(find.bySemanticsLabel('Loading'), findsNothing);
    await tester.pumpWidget(app(const LoadingRing(value: 0.8, onMedia: true)));
    expect(tester.takeException(), isNull);
  });
}
