import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'failure.dart';
import 'log.dart';

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
      log.warning('keyring', 'read of "$key" failed', e.message);
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
      log.warning('keyring', 'delete of "$key" failed', e.message);
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

/// A store of one file per key in a directory: for what is not secret and
/// may grow (the reader's preferences and bookmarks), which the keyring is
/// not meant for. Keys are the app's own: letters, digits and `-_=.`.
class FileKeyValueStore implements KeyValueStore {
  FileKeyValueStore(this._directory);

  final Future<Directory> Function() _directory;

  static final _validKey = RegExp(r'^[A-Za-z0-9_=-][A-Za-z0-9_=.-]*$');

  Future<File> _file(String key) async {
    if (!_validKey.hasMatch(key)) throw ArgumentError.value(key, 'key');
    final dir = await _directory();
    return File('${dir.path}${Platform.pathSeparator}$key.json');
  }

  /// A file that cannot be read means "nothing stored".
  @override
  Future<String?> read(String key) async {
    final file = await _file(key);
    try {
      return await file.readAsString();
    } on PathNotFoundException {
      return null;
    } on FileSystemException catch (e) {
      log.warning('storage', 'read of "$key" failed', e.message);
      return null;
    }
  }

  /// Written beside, then renamed over: a crash never leaves half a file.
  @override
  Future<void> write(String key, String value) async {
    final file = await _file(key);
    final part = File('${file.path}.part');
    try {
      await file.parent.create(recursive: true);
      await part.writeAsString(value, flush: true);
      await part.rename(file.path);
    } on FileSystemException catch (e) {
      throw StorageFailure(e.message, target: StorageTarget.disk);
    }
  }

  @override
  Future<void> delete(String key) async {
    final file = await _file(key);
    try {
      await file.delete();
    } on PathNotFoundException {
      // Already gone.
    } on FileSystemException catch (e) {
      log.warning('storage', 'delete of "$key" failed', e.message);
    }
  }
}
