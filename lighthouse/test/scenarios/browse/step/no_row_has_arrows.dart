import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/widgets/row_arrows.dart';

/// Usage: And no row has arrows
Future<void> noRowHasArrows(WidgetTester tester) async {
  expect(find.byKey(RowArrows.nextKey), findsNothing);
}
