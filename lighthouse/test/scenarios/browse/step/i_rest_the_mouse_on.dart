import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

import 'world.dart' as world;

/// Usage: When I rest the mouse on {'Test Movie'}
///
/// On its card; the mouse comes in from elsewhere when it is already on
/// the screen.
Future<void> iRestTheMouseOn(WidgetTester tester, String name) async {
  var mouse = world.mouse;
  if (mouse == null) {
    mouse = world.mouse = await tester.createGesture(
      kind: PointerDeviceKind.mouse,
    );
    addTearDown(() {
      world.mouse = null;
      return mouse!.removePointer();
    });
    await mouse.addPointer(location: Offset.zero);
  }
  await mouse.moveTo(tester.getCenter(world.cardOf(name)));
  await tester.pump();
}
