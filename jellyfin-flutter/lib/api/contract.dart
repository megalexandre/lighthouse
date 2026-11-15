import 'json_shape.dart';
import 'models/authenticate_user_by_name.dart';
import 'models/authentication_result.dart';
import 'models/base_item_dto.dart';
import 'models/base_item_dto_query_result.dart';
import 'models/public_system_info.dart';
import 'models/user_dto.dart';

/// What an endpoint answers with.
enum ResponseKind {
  /// 204, no body.
  none,

  /// A JSON object ([ApiEndpoint.response]).
  object,

  /// A JSON array of [ApiEndpoint.response] objects.
  list,

  /// A file (an image).
  file,
}

/// One endpoint the app calls, with the JSON it sends and reads.
class ApiEndpoint {
  const ApiEndpoint(
    this.method,
    this.path, {
    this.query = const [],
    this.request,
    this.response,
    ResponseKind? kind,
  }) : kind =
           kind ?? (response == null ? ResponseKind.none : ResponseKind.object);

  final String method;

  /// As in the OpenAPI document, e.g. `/Items/{itemId}`.
  final String path;

  /// Query parameters the app may send.
  final List<String> query;
  final JsonShape? request;
  final JsonShape? response;
  final ResponseKind kind;

  @override
  String toString() => '$method $path';
}

/// Every endpoint the app uses. When you add a call to the API layer, add
/// it here too: test/server/contract_test.dart checks this list against the
/// test server's OpenAPI document, and test/api/jellyfin_api_test.dart
/// checks that the API layer sends nothing that is not listed here.
const apiContract = [
  ApiEndpoint(
    'GET',
    '/System/Info/Public',
    response: PublicSystemInfo.jsonShape,
  ),
  ApiEndpoint(
    'POST',
    '/Users/AuthenticateByName',
    request: AuthenticateUserByName.jsonShape,
    response: AuthenticationResult.jsonShape,
  ),
  ApiEndpoint('GET', '/Users/Me', response: UserDto.jsonShape),
  ApiEndpoint('POST', '/Sessions/Logout'),
  ApiEndpoint(
    'GET',
    '/UserViews',
    query: ['userId'],
    response: BaseItemDtoQueryResult.jsonShape,
  ),
  ApiEndpoint(
    'GET',
    '/Items',
    query: [
      'userId',
      'parentId',
      'recursive',
      'includeItemTypes',
      'sortBy',
      'sortOrder',
      'startIndex',
      'limit',
      'fields',
    ],
    response: BaseItemDtoQueryResult.jsonShape,
  ),
  ApiEndpoint(
    'GET',
    '/Items/{itemId}',
    query: ['userId'],
    response: BaseItemDto.jsonShape,
  ),
  ApiEndpoint(
    'GET',
    '/Items/Latest',
    query: ['userId', 'parentId', 'limit'],
    response: BaseItemDto.jsonShape,
    kind: ResponseKind.list,
  ),
  ApiEndpoint(
    'GET',
    '/UserItems/Resume',
    query: ['userId', 'mediaTypes', 'limit'],
    response: BaseItemDtoQueryResult.jsonShape,
  ),
  ApiEndpoint(
    'GET',
    '/Shows/{seriesId}/Seasons',
    query: ['userId'],
    response: BaseItemDtoQueryResult.jsonShape,
  ),
  ApiEndpoint(
    'GET',
    '/Shows/{seriesId}/Episodes',
    query: ['userId', 'seasonId', 'fields'],
    response: BaseItemDtoQueryResult.jsonShape,
  ),
  ApiEndpoint(
    'GET',
    '/Shows/NextUp',
    query: ['userId', 'limit'],
    response: BaseItemDtoQueryResult.jsonShape,
  ),
  ApiEndpoint(
    'GET',
    '/Items/{itemId}/Images/{imageType}',
    query: ['tag', 'maxWidth', 'quality'],
    kind: ResponseKind.file,
  ),
];

/// The listed endpoint a request to [method] [path] (a concrete path, e.g.
/// /Items/abc) goes to, or null when none does. A literal path
/// (/Items/Latest) wins over a template (/Items/{itemId}).
ApiEndpoint? endpointFor(String method, String path) {
  final candidates = apiContract.where((e) => e.method == method);
  for (final e in candidates) {
    if (e.path == path) return e;
  }
  for (final e in candidates) {
    final template = e.path.replaceAll(RegExp(r'\{[^}]+\}'), '[^/]+');
    if (RegExp('^$template\$').hasMatch(path)) return e;
  }
  return null;
}
