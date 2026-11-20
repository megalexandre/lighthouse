import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/user_item_data_dto.dart';

import 'world.dart';

/// Usage: Given {'Test Movie'} was watched
Future<void> wasWatched(WidgetTester tester, String name) async {
  changeMovie(
    name,
    (m) => m.copyWith(userData: const UserItemDataDto(played: true)),
  );
}
