import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/app.dart';
import 'package:lighthouse/core/theme/design_tokens.dart';
import 'package:lighthouse/core/theme/theme_builder.dart';
import 'package:lighthouse/features/library/presentation/item_card.dart';
import 'package:lighthouse/l10n/l10n.dart';
import 'package:lighthouse/router.dart';
import 'package:lighthouse/widgets/skeleton.dart';
import 'package:material_ui/material_ui.dart';

import '../support/fakes.dart';

void main() {
  final theme = buildTheme(
    DesignTokens.parse(File('assets/themes/lanterna.json').readAsStringSync()),
    Brightness.dark,
  );

  Widget app(Widget child, {bool still = false, double textScale = 1}) =>
      MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            disableAnimations: still,
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: Scaffold(body: Center(child: child)),
      );

  testWidgets('a card skeleton is as tall as the card, at any font size', (
    tester,
  ) async {
    for (final scale in [1.0, 2.0]) {
      await tester.pumpWidget(
        app(const Skeleton(child: CardSkeleton(width: 140)), textScale: scale),
      );
      final context = tester.element(find.byType(CardSkeleton));
      expect(
        tester.getSize(find.byType(CardSkeleton)).height,
        ItemCard.heightFor(context, 140, 2 / 3),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('the sheen sweeps, and stays still without animations', (
    tester,
  ) async {
    await tester.pumpWidget(app(const Skeleton(child: Bone(width: 100))));
    expect(find.byType(ShaderMask), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isTrue);

    await tester.pumpWidget(
      app(const Skeleton(child: Bone(width: 100)), still: true),
    );
    expect(find.byType(ShaderMask), findsNothing);
    // Nothing left animating: settling ends.
    await tester.pumpAndSettle();
  });

  testWidgets('a screen reader hears "Loading"', (tester) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(app(const Skeleton(child: Bone(width: 100))));
    expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('a library shows its cards as a skeleton until they come', (
    tester,
  ) async {
    final test = TestApp();
    final gate = Completer<void>();
    test.library.held['children'] = gate;
    test.signIn();
    await test.pump(tester);
    ProviderScope.containerOf(tester.element(find.byType(LighthouseApp)))
        .read(routerProvider)
        .go(Routes.library(TestItems.moviesView.id));
    await tester.pump();
    await tester.pump();
    expect(find.byType(CardSkeleton), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    gate.complete();
    await tester.pumpAndSettle();
    expect(find.byType(Skeleton), findsNothing);
    expect(find.text(TestItems.testMovie.name), findsOneWidget);
  });
}
