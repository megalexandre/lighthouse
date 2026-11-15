import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'failure.dart';

/// Small string store for what must survive a restart (session, device id).
/// Production uses the system keyring; tests swap in [MemoryKeyValueStore]
/// through [keyValueStoreProvider].
abstract interface class KeyValueStore {
  Future<String?> read(String key);

  /// Throws [StorageFailure] when the value cannot be stored.
  Future<void> write(String key, String value);

  Future<void> delete(String key);
}

final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => SecureKeyValueStore(),
);

/// Keyring-backed store (libsecret on Linux).
class SecureKeyValueStore implements KeyValueStore {
  SecureKeyValueStore([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  /// A keyring that cannot be read (locked, missing) means "nothing
  /// stored": the user signs in again instead of the app failing to start.
  @override
  Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } on PlatformException catch (e) {
      debugPrint('keyring read of "$key" failed: ${e.message}');
      return null;
    }
  }

  @override
  Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } on PlatformException catch (e) {
      throw StorageFailure(e.message ?? e.code);
    }
  }

  @override
  Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } on PlatformException catch (e) {
      debugPrint('keyring delete of "$key" failed: ${e.message}');
    }
  }
}

class MemoryKeyValueStore implements KeyValueStore {
  MemoryKeyValueStore([Map<String, String>? values]) : values = values ?? {};

  final Map<String, String> values;

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}
