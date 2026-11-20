import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: Then the seek bar shows where it would go
Future<void> theSeekBarShowsWhereItWouldGo(WidgetTester tester) async {
  expect(_preview, findsOneWidget);
}

/// The preview over the seek bar (the time, and the picture when there is
/// trickplay) is the bar's only part that takes no touches.
Finder get _preview => find.descendant(
  of: find.byKey(PlayerScreen.seekBar),
  matching: find.byType(IgnorePointer),
);
