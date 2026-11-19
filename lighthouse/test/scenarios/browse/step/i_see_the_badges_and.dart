import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/widgets/media_badge.dart';

/// Usage: Then I see the badges {'1080P'}, {'5.1'} and {'CC'}
///
/// Those, and no other.
Future<void> iSeeTheBadgesAnd(
  WidgetTester tester,
  String first,
  String second,
  String third,
) async {
  expect(find.byType(MediaBadge), findsNWidgets(3));
  for (final badge in [first, second, third]) {
    expect(
      find.descendant(of: find.byType(MediaBadge), matching: find.text(badge)),
      findsOneWidget,
    );
  }
}
