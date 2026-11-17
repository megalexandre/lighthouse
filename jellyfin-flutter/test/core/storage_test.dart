import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/core/storage.dart';

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
}
