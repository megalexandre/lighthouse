import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/presentation/reader_screen.dart';
import 'package:material_ui/material_ui.dart';

const _values = {
  'Font size': ReaderScreen.fontSize,
  'Line height': ReaderScreen.lineSpacing,
  'Letter spacing': ReaderScreen.letterSpacing,
};

/// Usage: Then the display settings show {'100%'} for {'Font size'}
///
/// The value between that setting's two buttons.
Future<void> theDisplaySettingsShowFor(
  WidgetTester tester,
  String value,
  String setting,
) async {
  expect(tester.widget<Text>(find.byKey(_values[setting]!)).data, value);
}
