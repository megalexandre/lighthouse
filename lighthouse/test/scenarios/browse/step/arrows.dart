import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/widgets/row_arrows.dart';

import 'world.dart';

/// The 'next' or 'previous' arrow of the row with that title.
Finder arrowOf(String title, String way) => find.descendant(
  of: row(title),
  matching: find.byKey(
    way == 'next' ? RowArrows.nextKey : RowArrows.previousKey,
  ),
);
