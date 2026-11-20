import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/floating_top_bar.dart';

/// Usage: Then the top bar is titled {'Movies'}
///
/// On a phone a library's name is the top bar's title.
Future<void> theTopBarIsTitled(WidgetTester tester, String title) async {
  expect(
    find.descendant(
      of: find.byType(FloatingTopBar),
      matching: find.text(title),
    ),
    findsOneWidget,
  );
}
