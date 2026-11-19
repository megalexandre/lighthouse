import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/client_info.dart';
import '../../../api/jellyfin_api.dart';
import '../../../api/models/public_system_info.dart';
import '../../../api/system.dart';
import '../../../core/failure.dart';
import 'server_info.dart';
import 'server_url.dart';

abstract interface class ServerRepository {
  /// Checks that [input] (as typed by the user) points to a Jellyfin server
  /// that is ready for logins. Throws a [Failure] otherwise.
  Future<ServerInfo> probe(String input);
}

final serverRepositoryProvider = Provider<ServerRepository>(
  (ref) => JellyfinServerRepository(() => ref.read(clientInfoProvider.future)),
);

class JellyfinServerRepository implements ServerRepository {
  JellyfinServerRepository(this._client);

  final Future<ClientInfo> Function() _client;

  @override
  Future<ServerInfo> probe(String input) async {
    final url = normalizeServerUrl(input);
    if (url == null) throw NotJellyfinServer(input.trim());

    final api = JellyfinApi(baseUrl: url, client: await _client());
    final PublicSystemInfo info;
    try {
      info = await api.publicSystemInfo();
    } on ServerError {
      // A web server that is not Jellyfin: 404 or a page that is not JSON.
      throw NotJellyfinServer(url);
    }
    if (info.startupWizardCompleted == false) throw ServerNotSetUp(url);
    return ServerInfo(
      url: url,
      id: info.id,
      name: info.serverName,
      version: info.version,
    );
  }
}
