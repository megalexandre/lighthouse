import 'jellyfin_api.dart';
import 'models/public_system_info.dart';

extension SystemApi on JellyfinApi {
  /// Works without a login.
  Future<PublicSystemInfo> publicSystemInfo() =>
      getJson('/System/Info/Public', PublicSystemInfo.fromJson);
}
