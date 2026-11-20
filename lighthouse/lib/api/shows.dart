import 'jellyfin_api.dart';
import 'models/base_item_dto_query_result.dart';

extension ShowsApi on JellyfinApi {
  Future<BaseItemDtoQueryResult> seasons(String userId, String seriesId) =>
      getJson(
        '/Shows/$seriesId/Seasons',
        BaseItemDtoQueryResult.fromJson,
        query: {'userId': userId},
      );

  /// Episodes of [seriesId], only those of [seasonId] when given, in
  /// broadcast order.
  Future<BaseItemDtoQueryResult> episodes(
    String userId,
    String seriesId, {
    String? seasonId,
  }) => getJson(
    '/Shows/$seriesId/Episodes',
    BaseItemDtoQueryResult.fromJson,
    query: {
      'userId': userId,
      'seasonId': ?seasonId,
      'fields': ['Overview'],
    },
  );

  /// The next unwatched episode of each series the user is watching; of
  /// [seriesId] only, when given (12.4 then answers its first episode even
  /// when nothing of it was watched).
  Future<BaseItemDtoQueryResult> nextUp(
    String userId, {
    int? limit,
    String? seriesId,
  }) => getJson(
    '/Shows/NextUp',
    BaseItemDtoQueryResult.fromJson,
    query: {'userId': userId, 'limit': ?limit, 'seriesId': ?seriesId},
  );
}
