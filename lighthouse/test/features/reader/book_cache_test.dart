import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/reader/data/book_repository.dart';

void main() {
  final dir = Directory('/cache/books');

  test('a book is kept right inside the cache', () {
    final file = bookCacheFile(dir, 'server1', 'item1');
    expect(file.parent.path, dir.path);
  });

  test('ids from the server cannot leave the cache', () {
    for (final (server, item) in [
      ('server1', '../../.config/autostart/evil.desktop'),
      ('../..', 'item1'),
      ('/etc', 'passwd'),
      ('..', '..'),
      ('a\\..\\b', 'c'),
    ]) {
      final file = bookCacheFile(dir, server, item);
      expect(file.parent.path, dir.path, reason: '$server / $item');
      final name = file.uri.pathSegments.last;
      expect(name, matches(RegExp(r'^[A-Za-z0-9_=-]+$')));
    }
  });

  test('different servers or items never share a file', () {
    final names = {
      for (final (s, i) in [
        ('a', 'bc'),
        ('ab', 'c'),
        ('a-b', 'c'),
        ('a', 'b-c'),
      ])
        bookCacheFile(dir, s, i).path,
    };
    expect(names, hasLength(4));
  });
}
