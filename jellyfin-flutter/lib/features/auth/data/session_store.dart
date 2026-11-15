import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/log.dart';
import '../../../core/storage.dart';
import '../../server/data/server_info.dart';
import 'session.dart';

/// Persists the last server and the current session.
class SessionStore {
  SessionStore(this._store);

  static const serverKey = 'server';
  static const sessionKey = 'session';

  final KeyValueStore _store;

  Future<ServerInfo?> readServer() async =>
      _decode(await _store.read(serverKey), ServerInfo.fromJson);

  Future<Session?> readSession() async =>
      _decode(await _store.read(sessionKey), Session.fromJson);

  Future<void> writeServer(ServerInfo server) =>
      _store.write(serverKey, jsonEncode(server.toJson()));

  Future<void> writeSession(Session session) =>
      _store.write(sessionKey, jsonEncode(session.toJson()));

  Future<void> clearServer() => _store.delete(serverKey);

  Future<void> clearSession() => _store.delete(sessionKey);

  /// Unreadable data (an older app version, corruption) counts as nothing
  /// stored: the user signs in again.
  T? _decode<T>(String? text, T Function(Map<String, dynamic>) fromJson) {
    if (text == null) return null;
    try {
      return fromJson(jsonDecode(text) as Map<String, dynamic>);
    } on Object catch (e) {
      log.warning('session', 'ignoring a stored value that cannot be read', e);
      return null;
    }
  }
}

final sessionStoreProvider = Provider<SessionStore>(
  (ref) => SessionStore(ref.watch(keyValueStoreProvider)),
);
