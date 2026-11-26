import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/player_screen.dart';

/// Usage: Then the side panel is open
Future<void> theSidePanelIsOpen(WidgetTester tester) async {
  expect(find.byKey(PlayerScreen.sidePanel), findsOneWidget);
}
