import 'json_shape.dart';
import 'models/authenticate_user_by_name.dart';
import 'models/authentication_result.dart';
import 'models/public_system_info.dart';
import 'models/user_dto.dart';

/// One endpoint the app calls, with the JSON it sends and reads.
class ApiEndpoint {
  const ApiEndpoint(this.method, this.path, {this.request, this.response});

  final String method;
  final String path;
  final JsonShape? request;

  /// Null when the app reads no body (204).
  final JsonShape? response;

  @override
  String toString() => '$method $path';
}

/// Every endpoint the app uses. When you add a call to the API layer, add
/// it here too: test/server/contract_test.dart checks this list against the
/// test server's OpenAPI document.
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
];
