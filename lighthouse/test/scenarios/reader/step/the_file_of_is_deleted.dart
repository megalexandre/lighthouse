import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: And the file of {'voice-1.wav'} is deleted
Future<void> theFileOfIsDeleted(WidgetTester tester, String file) async {
  expect(File('${app.voiceNotes.path}/$file').existsSync(), isFalse);
}
