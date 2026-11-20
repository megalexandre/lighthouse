import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/core/storage.dart';

void main() {
  late Directory dir;
  late FileKeyValueStore store;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('jf-store-');
    addTearDown(() => dir.delete(recursive: true));
    // A folder not made yet: the first write makes it.
    store = FileKeyValueStore(() async => Directory('${dir.path}/reader'));
  });

  test('a value is kept, replaced and deleted', () async {
    expect(await store.read('preferences'), isNull);
    await store.write('preferences', '{"a":1}');
    expect(await store.read('preferences'), '{"a":1}');
    await store.write('preferences', '{"a":2}');
    expect(await store.read('preferences'), '{"a":2}');
    // Nothing left beside it.
    expect(
      Directory('${dir.path}/reader')
          .listSync()
          .map((f) => f.uri.pathSegments.last),
      ['preferences.json'],
    );
    await store.delete('preferences');
    await store.delete('preferences'); // Already gone: fine.
    expect(await store.read('preferences'), isNull);
  });

  test('keys that could leave the folder are refused', () async {
    for (final key in ['../x', 'a/b', '.hidden', '', r'a\b']) {
      expect(() => store.write(key, 'v'), throwsArgumentError, reason: key);
    }
    expect(await store.read('bookmarks-c2VydmVy_aXRlbQ=='), isNull);
  });

  test('a folder it may not use: reading is "nothing stored", writing '
      'fails and says where, deleting goes on', () async {
    await store.write('preferences', '{"a":1}');
    final folder = '${dir.path}/reader';
    await Process.run('chmod', ['000', folder]);
    addTearDown(() => Process.run('chmod', ['755', folder]));

    expect(await store.read('preferences'), isNull);
    await expectLater(
      store.write('preferences', '{"a":2}'),
      throwsA(
        isA<StorageFailure>().having(
          (e) => e.target,
          'target',
          StorageTarget.disk,
        ),
      ),
    );
    await store.delete('preferences');
  });

  test('a keyring that cannot be used (locked, missing): reading is '
      '"nothing stored", writing fails, deleting goes on', () async {
    final keyring = SecureKeyValueStore(_LockedKeyring());
    expect(await keyring.read('session'), isNull);
    await expectLater(
      keyring.write('session', 'x'),
      throwsA(
        isA<StorageFailure>()
            .having((e) => e.detail, 'detail', 'The keyring is locked')
            .having((e) => e.target, 'target', StorageTarget.keyring),
      ),
    );
    await keyring.delete('session');
  });
}

/// A keyring that refuses everything, as libsecret does when locked.
class _LockedKeyring extends Fake implements FlutterSecureStorage {
  static final _locked = PlatformException(
    code: 'Libsecret error',
    message: 'The keyring is locked',
  );

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => throw _locked;

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => throw _locked;

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => throw _locked;
}
