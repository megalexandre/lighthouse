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

/// Connect screen: the server at [addresses] (as typed, preferred first),
/// reached at the first one that answers.
///
/// Every address is probed at once, and all are waited for, so one that
/// reaches a different server is caught now and not on the day the
/// preferred one is down. One that does not answer is kept unchecked: a
/// fallback is often unreachable from where it is set up (no hairpin NAT at
/// home), and [locateServer] only ever moves to the same server.
///
/// When none answers, the preferred address's failure is reported, unless
/// another one's certificate was refused (the user can fix that).
Future<ServerInfo> connectServer(
  List<String> addresses,
  Future<ServerInfo> Function(String address) probe,
) async {
  final results = await Future.wait([
    for (final address in addresses)
      probe(address).then<Object>((s) => s, onError: (Object e) => e),
  ]);
  ServerInfo? found;
  for (final (i, result) in results.indexed) {
    if (result is! ServerInfo) continue;
    if (found == null) {
      found = result;
    } else if (result.id != found.id) {
      throw DifferentServer(addresses[i]);
    }
  }
  if (found != null) {
    return found.copyWith(addresses: addresses.length > 1 ? addresses : []);
  }
  throw results
          .whereType<ServerError>()
          .where((e) => e.badCertificate)
          .firstOrNull ??
      results.first;
}

/// Where [server] answers now: the first of its addresses, in order, that
/// reaches the same server (same id), with what that answer says of it.
/// Throws [ServerUnreachable] (for the address in use) when none does.
///
/// At startup and after an outage, so the home address wins whenever it
/// works and the fallback takes over when it does not. Probed at once, like
/// [probeInOrder]: a preferred address that never answers costs one
/// timeout.
Future<ServerInfo> locateServer(
  ServerInfo server,
  Future<ServerInfo> Function(String address) probe,
) async {
  final attempts = [for (final address in server.candidates) probe(address)];
  for (final attempt in attempts) {
    attempt.ignore();
  }
  for (final attempt in attempts) {
    try {
      final found = await attempt;
      if (found.id == server.id) {
        return found.copyWith(addresses: server.addresses);
      }
    } on Failure {
      // Try the next one.
    }
  }
  throw ServerUnreachable(server.url);
}
