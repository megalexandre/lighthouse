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
    final urls = serverUrlCandidates(input);
    if (urls.isEmpty) throw NotJellyfinServer(input.trim());
    final client = await _client();
    return probeInOrder(urls, (url) => _probeOne(url, client));
  }

  Future<ServerInfo> _probeOne(String url, ClientInfo client) async {
    final api = JellyfinApi(baseUrl: url, client: client);
    final PublicSystemInfo info;
    try {
      info = await api.publicSystemInfo();
    } on ServerError catch (e) {
      // The user can act on a refused certificate; say so.
      if (e.badCertificate) rethrow;
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

/// Probes every one of [urls] at once and answers with the first, in the
/// list's order, that reached a server. All at once so an address that never
/// answers costs one timeout, not one per candidate; in order so https wins
/// over http whenever both answer.
///
/// A server that is Jellyfin but not set up ends the search: it was found.
/// When none answers, a refused certificate is the failure reported (the
/// user can fix it), otherwise the last candidate's, the most conventional
/// address (Jellyfin's own port).
Future<ServerInfo> probeInOrder(
  List<String> urls,
  Future<ServerInfo> Function(String url) probe,
) async {
  final attempts = [for (final url in urls) probe(url)];
  // Those after the winner are never awaited; their errors must not surface.
  for (final attempt in attempts) {
    attempt.ignore();
  }
  ServerError? certificate;
  Failure? last;
  for (final attempt in attempts) {
    try {
      return await attempt;
    } on ServerNotSetUp {
      rethrow;
    } on ServerError catch (e) {
      if (e.badCertificate) certificate ??= e;
      last = e;
    } on Failure catch (e) {
      last = e;
    }
  }
  throw certificate ?? last!;
}
