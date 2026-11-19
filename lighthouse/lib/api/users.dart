import 'jellyfin_api.dart';
import 'models/authenticate_user_by_name.dart';
import 'models/authentication_result.dart';
import 'models/user_dto.dart';

extension UsersApi on JellyfinApi {
  /// Throws Unauthorized on a wrong username or password.
  Future<AuthenticationResult> authenticateByName(
    String username,
    String password,
  ) => postJson(
    '/Users/AuthenticateByName',
    AuthenticationResult.fromJson,
    body: AuthenticateUserByName(username: username, pw: password).toJson(),
  );

  /// The signed-in user. Throws Unauthorized when the token is no longer
  /// valid.
  Future<UserDto> me() => getJson('/Users/Me', UserDto.fromJson);

  /// The user's settings as the server sends them, every field included,
  /// so an update can send them all back (the server replaces the lot).
  Future<Map<String, dynamic>> myConfigurationJson() => getJson(
    '/Users/Me',
    (json) => (json['Configuration'] as Map<String, dynamic>?) ?? {},
  );

  Future<void> updateConfiguration(
    String userId,
    Map<String, dynamic> configuration,
  ) => guard(
    (dio) => dio.post<void>(
      '/Users/Configuration',
      queryParameters: {'userId': userId},
      data: configuration,
    ),
  );
}
