import 'jellyfin_api.dart';
import 'models/base_item_dto.dart';
import 'models/base_item_dto_query_result.dart';

/// Sort orders the app asks for (`sortBy`).
abstract final class ItemSort {
  static const name = 'SortName';
  static const index = 'IndexNumber';
  static const parentIndex = 'ParentIndexNumber';
}

extension ItemsApi on JellyfinApi {
  /// The user's libraries, in the order they arranged them.
  Future<BaseItemDtoQueryResult> userViews(String userId) => getJson(
    '/UserViews',
    BaseItemDtoQueryResult.fromJson,
    query: {'userId': userId},
  );

  /// Items under [parentId] (a library or folder), one page at a time.
  /// With [recursive], whole subtrees, usually narrowed by
  /// [includeItemTypes] (all movies of a library, not its folders).
  Future<BaseItemDtoQueryResult> items({
    required String userId,
    String? parentId,
    bool recursive = false,
    List<BaseItemKind> includeItemTypes = const [],
    List<String> sortBy = const [ItemSort.name],
    bool descending = false,
    int? startIndex,
    int? limit,
    List<String> fields = const [],
    String? searchTerm,
  }) => getJson(
    '/Items',
    BaseItemDtoQueryResult.fromJson,
    query: {
      'userId': userId,
      'parentId': ?parentId,
      'recursive': recursive,
      if (includeItemTypes.isNotEmpty)
        'includeItemTypes': [for (final t in includeItemTypes) t.jsonValue],
      'sortBy': sortBy,
      'sortOrder': descending ? 'Descending' : 'Ascending',
      'startIndex': ?startIndex,
      'limit': ?limit,
      if (fields.isNotEmpty) 'fields': fields,
      'searchTerm': ?searchTerm,
    },
  );

  /// One item with all its fields.
  Future<BaseItemDto> item(String userId, String itemId) => getJson(
    '/Items/$itemId',
    BaseItemDto.fromJson,
    query: {'userId': userId},
  );

  /// Recently added under [parentId] (a library), newest first. Episodes of
  /// one series come back grouped as that series.
  Future<List<BaseItemDto>> latest(
    String userId, {
    String? parentId,
    int? limit,
  }) => getJsonList(
    '/Items/Latest',
    BaseItemDto.fromJson,
    query: {'userId': userId, 'parentId': ?parentId, 'limit': ?limit},
  );

  /// Partly watched videos ("Continue watching"), last watched first.
  Future<BaseItemDtoQueryResult> resume(String userId, {int? limit}) => getJson(
    '/UserItems/Resume',
    BaseItemDtoQueryResult.fromJson,
    query: {
      'userId': userId,
      'mediaTypes': ['Video'],
      'limit': ?limit,
    },
  );
}
