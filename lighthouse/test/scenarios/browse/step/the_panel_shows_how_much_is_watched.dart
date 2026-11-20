import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/library/presentation/card_popover.dart';

/// Usage: And the panel shows how much is watched
///
/// A bar under its picture.
Future<void> thePanelShowsHowMuchIsWatched(WidgetTester tester) async {
  expect(find.byKey(CardPopover.progress), findsOneWidget);
}
