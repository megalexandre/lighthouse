import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../../api/books.dart';
import '../../../api/client_info.dart';
import '../../../api/models/base_item_dto.dart';
import '../../../api/playback.dart';
import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../../core/storage.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/data/session.dart';
import '../../auth/data/session_client.dart';
import '../../server/application/connection_controller.dart';

/// Books for the reader: their files (downloaded once, then read from a
/// local cache) and the user's place in them, kept on the server.
abstract interface class BookRepository {
  /// The book's file, downloading it the first time.
  Future<File> file(BaseItemDto book);

  /// Saves where the user is (see reading_position.dart for the scale).
  Future<void> savePosition(String itemId, int positionTicks);

  /// Marks the book read or not.
  Future<void> setRead(String itemId, {required bool read});

  /// The user's bookmarks in the book, each a fraction of it (from 0 to
  /// 1, as [BookDocument.fractionOf] tells a page's place), in order.
  /// Kept on this device: the server has no place for them.
  Future<List<double>> bookmarks(String itemId);

  Future<void> saveBookmarks(String itemId, List<double> bookmarks);
}

/// The reader's own files (preferences, bookmarks): small, not secret, in
/// the app's data directory.
final readerStoreProvider = Provider<KeyValueStore>(
  (_) => FileKeyValueStore(
    () async =>
        Directory('${(await getApplicationSupportDirectory()).path}/reader'),
  ),
);

/// Where downloaded books are kept: the app's cache directory.
final bookCacheDirectoryProvider = FutureProvider<Directory>(
  (_) async =>
      Directory('${(await getApplicationCacheDirectory()).path}/books'),
);

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  final session = ref.watch(
    authControllerProvider.select((auth) => auth.value?.session),
  );
  if (session == null) return const SignedOutBookRepository();
  // Read now, not when a call finishes (see library_repository.dart).
  final client = ref.read(clientInfoProvider.future);
  final auth = ref.read(authControllerProvider.notifier);
  final connection = ref.read(connectionProvider.notifier);
  final cache = ref.read(bookCacheDirectoryProvider.future);
  return JellyfinBookRepository(
    session,
    () => client,
    () => cache,
    ref.read(readerStoreProvider),
    onUnauthorized: auth.sessionExpired,
    onReachability: connection.report,
  );
});

class JellyfinBookRepository implements BookRepository {
  JellyfinBookRepository(
    Session session,
    Future<ClientInfo> Function() client,
    this._cache,
    this._store, {
    required void Function() onUnauthorized,
    void Function({required bool reachable})? onReachability,
    HttpClientAdapter? adapter,
  }) : _client = SessionClient(
         session,
         client,
         onUnauthorized: onUnauthorized,
         onReachability: onReachability,
         adapter: adapter,
       );

  final SessionClient _client;
  final Future<Directory> Function() _cache;
  final KeyValueStore _store;

  @override
  Future<File> file(BaseItemDto book) async {
    final dir = await _cache();
    await dir.create(recursive: true);
    final file = bookCacheFile(dir, _client.session.server.id, book.id);
    if (file.existsSync() && file.lengthSync() > 0) return file;

    // Downloaded beside, then renamed: an interrupted download never
    // leaves half a book behind.
    final part = File('${file.path}.part');
    try {
      await _client.call((api) => api.downloadItem(book.id, part.path));
      await part.rename(file.path);
    } finally {
      if (part.existsSync()) await part.delete();
    }
    return file;
  }

  @override
  Future<void> savePosition(String itemId, int positionTicks) => _client.call(
    (api) => api.setPosition(_client.userId, itemId, positionTicks),
  );

  @override
  Future<void> setRead(String itemId, {required bool read}) => _client.call(
    (api) => read
        ? api.markPlayed(_client.userId, itemId)
        : api.markUnplayed(_client.userId, itemId),
  );

  /// One file per server and book (named as in [bookCacheFile]).
  String _bookmarksKey(String itemId) =>
      'bookmarks-${base64Url.encode(utf8.encode('${_client.session.server.id}\n$itemId'))}';

  @override
  Future<List<double>> bookmarks(String itemId) async {
    final raw = await _store.read(_bookmarksKey(itemId));
    if (raw == null) return const [];
    try {
      return [
        for (final value in jsonDecode(raw) as List<dynamic>)
          if (value is num && value >= 0 && value <= 1) value.toDouble(),
      ]..sort();
    } on Object catch (e) {
      log.warning('reader', 'bookmarks of $itemId unreadable', e);
      return const [];
    }
  }

  @override
  Future<void> saveBookmarks(String itemId, List<double> bookmarks) =>
      bookmarks.isEmpty
      ? _store.delete(_bookmarksKey(itemId))
      : _store.write(_bookmarksKey(itemId), jsonEncode(bookmarks));
}

/// Where [itemId] of [serverId] is kept in [dir]: one file per server and
/// item (a book edited on the server keeps its id: clearing the cache gets
/// the new file).
///
/// Both ids come from the server, so they are never put in the path as
/// they are: an id like `../../.config/autostart/x` would write outside
/// the cache. Encoded (base64url: letters, digits, `-`, `_`, `=`), they
/// can be neither a separator nor `..`; the check after is a second lock.
File bookCacheFile(Directory dir, String serverId, String itemId) {
  final name = base64Url.encode(utf8.encode('$serverId\n$itemId'));
  final file = File('${dir.path}${Platform.pathSeparator}$name');
  if (file.parent.absolute.path != dir.absolute.path) {
    throw StateError('Book cache path outside the cache: ${file.path}');
  }
  return file;
}

/// While nobody is signed in (see SignedOutLibraryRepository).
class SignedOutBookRepository implements BookRepository {
  const SignedOutBookRepository();

  @override
  Future<File> file(BaseItemDto book) => Future.error(const Unauthorized());

  @override
  Future<void> savePosition(String itemId, int positionTicks) =>
      Future.error(const Unauthorized());

  @override
  Future<void> setRead(String itemId, {required bool read}) =>
      Future.error(const Unauthorized());

  @override
  Future<List<double>> bookmarks(String itemId) =>
      Future.error(const Unauthorized());

  @override
  Future<void> saveBookmarks(String itemId, List<double> bookmarks) =>
      Future.error(const Unauthorized());
}
