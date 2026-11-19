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
    this.cacheLimit = defaultCacheLimit,
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

  /// The most the downloaded books may take, in bytes: past it, the ones
  /// opened longest ago go (they download again when opened).
  final int cacheLimit;
  static const defaultCacheLimit = 2 * 1024 * 1024 * 1024;

  /// Downloads under way, by the book's cache path. The reader can close
  /// while a book downloads (the download goes on) and open it again: the
  /// second request waits for the first instead of starting another.
  final _downloads = <String, Future<File>>{};

  /// Names this download's temporary file apart from any other's.
  int _downloadCount = 0;

  @override
  Future<File> file(BaseItemDto book) async {
    final dir = await _cache();
    await dir.create(recursive: true);
    final file = bookCacheFile(dir, _client.session.server.id, book.id);
    if (file.existsSync() && file.lengthSync() > 0) {
      _markUsed(file);
    } else {
      await (_downloads[file.path] ??= _download(book, file).whenComplete(() {
        // A block, not `=>`: remove() returns this very future, and
        // whenComplete would wait for it, forever.
        _downloads.remove(file.path);
      }));
    }
    await _trim(dir, keep: file);
    return file;
  }

  /// Opened now: the last to go when the cache is trimmed. The file's
  /// modification time says so (access times are often not kept).
  void _markUsed(File file) {
    try {
      file.setLastModifiedSync(DateTime.now());
    } on FileSystemException catch (e) {
      log.warning('reader', 'cache: cannot mark a book used', e);
    }
  }

  /// Keeps the books within [cacheLimit] (see [booksToEvict]); [keep] is
  /// the one being opened.
  Future<void> _trim(Directory dir, {required File keep}) async {
    final books = <CachedBook>[];
    try {
      await for (final entry in dir.list()) {
        // Temporary files are downloads under way (or their leftovers,
        // which _removeLeftovers clears).
        if (entry is! File || entry.path.endsWith(_partSuffix)) continue;
        final stat = entry.statSync();
        books.add((path: entry.path, size: stat.size, used: stat.modified));
      }
    } on FileSystemException catch (e) {
      log.warning('reader', 'cache: cannot list the books', e);
      return;
    }
    for (final path in booksToEvict(books, cacheLimit, keep: keep.path)) {
      try {
        await File(path).delete();
        log.info('reader', 'cache: removed a book opened long ago');
      } on FileSystemException catch (e) {
        log.warning('reader', 'cache: cannot remove a book', e);
      }
    }
  }

  /// Downloads [book] beside [file], then renames it: an interrupted
  /// download never leaves half a book behind, and the temporary name is
  /// this download's own, so no other one (another run of the app) ever
  /// writes into it.
  Future<File> _download(BaseItemDto book, File file) async {
    await _removeLeftovers(file);
    final part = File('${file.path}.$pid-${_downloadCount++}$_partSuffix');
    try {
      await _client.call((api) => api.downloadItem(book.id, part.path));
      await part.rename(file.path);
    } finally {
      if (part.existsSync()) await part.delete();
    }
    return file;
  }

  static const _partSuffix = '.part';

  /// Temporary files of [file] left by a run that was killed mid-download.
  /// One written to in the last minute may be another app's download under
  /// way: left alone.
  Future<void> _removeLeftovers(File file) async {
    final name = file.uri.pathSegments.last;
    final stale = DateTime.now().subtract(const Duration(minutes: 1));
    await for (final entry in file.parent.list()) {
      final other = entry.uri.pathSegments.last;
      if (entry is File &&
          other.startsWith('$name.') &&
          other.endsWith(_partSuffix)) {
        try {
          if (entry.statSync().modified.isBefore(stale)) await entry.delete();
        } on FileSystemException {
          // Gone already, or not ours to delete: the download goes on.
        }
      }
    }
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

/// A downloaded book: its file, its size, and when it was last opened.
typedef CachedBook = ({String path, int size, DateTime used});

/// Which of [books] to remove so the rest take at most [limit] bytes: the
/// ones opened longest ago first; never [keep] (the book being opened),
/// even when it alone is over the limit.
List<String> booksToEvict(
  List<CachedBook> books,
  int limit, {
  required String keep,
}) {
  var total = books.fold(0, (sum, b) => sum + b.size);
  final oldestFirst = [...books]..sort((a, b) => a.used.compareTo(b.used));
  final evicted = <String>[];
  for (final book in oldestFirst) {
    if (total <= limit) break;
    if (book.path == keep) continue;
    evicted.add(book.path);
    total -= book.size;
  }
  return evicted;
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
