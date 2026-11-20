import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/player/presentation/osd/seek_bar.dart';

/// Usage: Then I see the picture of that moment
///
/// The trickplay picture in the preview, once its tile is fetched and
/// decoded (real work, so off the test's fake clock).
Future<void> iSeeThePictureOfThatMoment(WidgetTester tester) async {
  final picture = find.byKey(SeekBar.thumbnailKey);
  for (var i = 0; i < 50 && picture.evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }
  expect(picture, findsOneWidget);
}
