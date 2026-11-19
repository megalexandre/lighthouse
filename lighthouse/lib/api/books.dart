import 'jellyfin_api.dart';
import 'models/update_user_item_data_dto.dart';
import 'models/user_item_data_dto.dart';

extension BooksApi on JellyfinApi {
  /// Saves where the user is in a book. The server keeps a book's place as
  /// a playback position: 12.4 gives a PDF or a comic a "length" of
  /// 10000 ticks per page (see reader/data/reading_position.dart).
  Future<UserItemDataDto> setPosition(
    String userId,
    String itemId,
    int positionTicks,
  ) => postJson(
    '/UserItems/$itemId/UserData',
    UserItemDataDto.fromJson,
    query: {'userId': userId},
    body: UpdateUserItemDataDto(playbackPositionTicks: positionTicks).toJson(),
  );

  /// Downloads the book's file to [path].
  Future<void> downloadItem(String itemId, String path) =>
      guard((dio) => dio.download('/Items/$itemId/Download', path));
}
