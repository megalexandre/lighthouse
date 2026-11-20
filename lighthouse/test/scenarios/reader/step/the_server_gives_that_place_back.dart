import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';

import 'world.dart';

/// Usage: And the server gives that place back
///
/// The fake server keeps no state: it now lists the book at the place it
/// was last told.
Future<void> theServerGivesThatPlaceBack(WidgetTester tester) async {
  final (id, position) = app.books.saved.last;
  changeBook(
    id,
    (b) =>
        b.copyWith(userData: UserItemDataDto(playbackPositionTicks: position)),
  );
}
