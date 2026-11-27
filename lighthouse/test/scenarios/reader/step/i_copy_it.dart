import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';

import 'world.dart';

/// Usage: When I copy it
///
/// Copy, in the menu over the selection; what it copies is kept in
/// [clipboard].
Future<void> iCopyIt(WidgetTester tester) async {
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (call) async {
      if (call.method == 'Clipboard.setData') {
        clipboard =
            (call.arguments as Map<Object?, Object?>)['text'] as String?;
      }
      return null;
    },
  );
  addTearDown(
    () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    ),
  );
  await tester.tap(find.byKey(ReaderScreen.copyButton));
  await tester.pumpAndSettle();
}
