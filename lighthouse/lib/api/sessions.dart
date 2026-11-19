import 'jellyfin_api.dart';

extension SessionsApi on JellyfinApi {
  /// Revokes this client's token on the server.
  Future<void> logout() => post('/Sessions/Logout');
}
