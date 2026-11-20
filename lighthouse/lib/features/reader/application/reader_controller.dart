import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show Offset, Size;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../library/application/library_providers.dart';
import '../../library/data/library_repository.dart';
import '../data/book_document.dart';
import '../data/book_repository.dart';
import '../data/epub/epub_layout.dart';
import '../data/reading_position.dart';
import 'pending_reading.dart';
import 'reader_preferences.dart';

/// Opens a book file (tests swap in their own documents).
final bookOpenerProvider = Provider<Future<BookDocument> Function(File file)>(
  (_) => openBook,
);

/// A book open in the reader, and the page shown (0-based).
@immutable
class ReaderSession {
  const ReaderSession({
    required this.item,
    required this.document,
    required this.page,
    this.bookmarks = const [],
    this.linkedFrom,
  });

  final BaseItemDto item;
  final BookDocument document;
  final int page;

  /// The user's bookmarks, as fractions of the book (see
  /// [BookRepository.bookmarks]).
  final List<double> bookmarks;

  /// Where the reader was when they followed a link (a fraction of the
  /// book), until they go back there.
  final double? linkedFrom;

  int get pageCount => document.pageCount;
  bool get onLastPage => page == pageCount - 1;

  /// Whether a bookmark falls on the page shown.
  bool get bookmarked => bookmarks.any((f) => document.pageAt(f) == page);

  ReaderSession copyWith({
    int? page,
    List<double>? bookmarks,
    double? Function()? linkedFrom,
  }) => ReaderSession(
    item: item,
    document: document,
    page: page ?? this.page,
    bookmarks: bookmarks ?? this.bookmarks,
    linkedFrom: linkedFrom == null ? this.linkedFrom : linkedFrom(),
  );
}

final readerControllerProvider = AsyncNotifierProvider.autoDispose
    .family<ReaderController, ReaderSession, String>(ReaderController.new);

/// Reads one book: downloads and opens it at the saved place, turns pages,
/// and keeps the server up to date (the place, once the reader stays on a
/// page for [saveDelay]; "read" on reaching the last page).
class ReaderController extends AsyncNotifier<ReaderSession> {
  ReaderController(this.itemId);

  final String itemId;

  /// Turning several pages quickly saves only where the reader stops.
  static const saveDelay = Duration(seconds: 1);

  Timer? _saveTimer;

  /// The place to save, taken when the page was turned to (an EPUB's page
  /// numbers change with the window; its place does not).
  ({int position, bool last})? _unsaved;
  bool _markedRead = false;
  ReaderSession? _session;
  late final BookRepository _books = ref.read(bookRepositoryProvider);
  late final PendingReading _pending = ref.read(
    pendingReadingProvider.notifier,
  );

  @override
  Future<ReaderSession> build() async {
    ref.onDispose(_release);
    // Read before the first await: the reader can close while the book
    // downloads, and a closed controller's ref cannot be read.
    final books = _books;
    final pending = _pending;
    final unsent = ref.read(pendingReadingProvider)[itemId];
    final open = ref.read(bookOpenerProvider);
    final item = await ref.read(libraryRepositoryProvider).item(itemId);
    final file = await books.file(item);
    final document = await open(file);
    if (!ref.mounted) {
      await document.dispose();
      throw const NotReadable('a book closed while opening');
    }
    try {
      _typography = (await ref.read(readerPreferencesProvider.future))
          .typography;
    } on Object catch (e) {
      log.warning('reader', 'preferences not read', e);
    }
    // A new size or typeface: the pages are cut again.
    ref.listen(readerPreferencesProvider, (_, next) {
      final typography = next.value?.typography;
      if (typography == null || typography == _typography) return;
      _typography = typography;
      _relayout();
    });
    var bookmarks = const <double>[];
    try {
      bookmarks = await _books.bookmarks(itemId);
    } on Object catch (e) {
      log.warning('reader', 'bookmarks not read', e);
    }
    if (!ref.mounted) {
      await document.dispose();
      throw const NotReadable('a book closed while opening');
    }
    final data = item.userData;
    // A place the server has not heard of yet is newer than its own; read
    // to the end opens at the start, as a book the server has as read.
    final read = unsent?.read ?? (data?.played ?? false);
    _markedRead = data?.played ?? false;
    final fraction = read
        ? 0.0
        : fractionForPosition(
            unsent?.position ?? data?.playbackPositionTicks ?? 0,
            document.pageCount,
            item.runTimeTicks,
          );
    if (unsent != null) {
      log.info('reader', '"${item.name}": opened at a place not sent yet');
      pending.flush();
    }
    // An EPUB has no pages yet: it opens there once laid out.
    if (document.reflowable) _openAt = fraction;
    final start = document.pageAt(fraction);
    log.info(
      'reader',
      document.reflowable
          ? '"${item.name}": EPUB, opened at ${(fraction * 100).round()} %'
          : '"${item.name}": ${document.pageCount} pages, '
                'opened at ${start + 1}',
    );
    return _session = ReaderSession(
      item: item,
      document: document,
      page: start,
      bookmarks: bookmarks,
    );
  }

  /// Where a reflowable book opens, until its first layout.
  double? _openAt;

  /// The sheet size and type a reflowable book is laid out for.
  Size? _size;
  EpubTypography _typography = const EpubTypography();

  /// Lays a reflowable book (an EPUB) out in pages of [size], the sheet
  /// the screen shows, keeping the reader where they were: on the page
  /// that holds the first word they could see.
  void layout(Size size) {
    _size = size;
    _relayout();
  }

  void _relayout() {
    final session = _session;
    final size = _size;
    if (session == null || size == null) return;
    final document = session.document;
    final fraction =
        _openAt ??
        (document.pageCount > 0 ? document.fractionOf(session.page) : 0.0);
    if (!document.layout(size, _typography)) return;
    _openAt = null;
    log.debug(
      'reader',
      '${document.pageCount} pages of ${size.width.round()} × '
          '${size.height.round()}, ${_typography.fontSize} px type',
    );
    _set(session.copyWith(page: document.pageAt(fraction)));
  }

  void _set(ReaderSession session) {
    _session = session;
    state = AsyncData(session);
  }

  /// Shows the page at [fraction] of the book (a line of the contents, a
  /// bookmark).
  void goToFraction(double fraction) {
    final session = _session;
    if (session == null) return;
    goTo(session.document.pageAt(fraction));
  }

  /// Follows the link at [at] on page [page] (the page shown unless said:
  /// with two side by side, the one tapped; [at] in the page's unit
  /// square), if there is one there; remembers where it was followed from
  /// ([ReaderSession.linkedFrom]). True when there was one.
  bool followLink(Offset at, {int? page}) {
    final session = _session;
    if (session == null) return false;
    final target = session.document.linkAt(page ?? session.page, at);
    if (target == null) return false;
    final from = session.document.fractionOf(session.page);
    _set(session.copyWith(linkedFrom: () => from));
    goToFraction(target);
    return true;
  }

  /// Back to where the last link was followed from.
  void returnFromLink() {
    final from = _session?.linkedFrom;
    if (from == null) return;
    _set(_session!.copyWith(linkedFrom: () => null));
    goToFraction(from);
  }

  /// Adds a bookmark on the page shown, or removes those on it. Kept on
  /// this device (see [BookRepository.bookmarks]).
  Future<void> toggleBookmark() async {
    final session = _session;
    if (session == null || session.pageCount == 0) return;
    final document = session.document;
    final bookmarks = session.bookmarked
        ? [
            for (final f in session.bookmarks)
              if (document.pageAt(f) != session.page) f,
          ]
        : ([...session.bookmarks, document.fractionOf(session.page)]..sort());
    _set(session.copyWith(bookmarks: bookmarks));
    await _saveBookmarks(bookmarks);
  }

  /// Removes the bookmark at [fraction].
  Future<void> removeBookmark(double fraction) async {
    final session = _session;
    if (session == null) return;
    final bookmarks = [
      for (final f in session.bookmarks)
        if (f != fraction) f,
    ];
    _set(session.copyWith(bookmarks: bookmarks));
    await _saveBookmarks(bookmarks);
  }

  Future<void> _saveBookmarks(List<double> bookmarks) async {
    try {
      await _books.saveBookmarks(itemId, bookmarks);
    } on Failure catch (e) {
      log.warning('reader', 'could not save the bookmarks', e);
    }
  }

  /// Shows [page] (0-based, clamped to the book). [through]: the last page
  /// shown with it, when there are two side by side; reaching the book's
  /// last page that way marks it read too.
  void goTo(int page, {int? through}) {
    final session = _session;
    if (session == null) return;
    final target = page.clamp(0, session.pageCount - 1);
    if (target == session.page) return;
    final linkedFrom = session.linkedFrom;
    _set(
      session.copyWith(
        page: target,
        // Back on the page the link was followed from: done with it.
        linkedFrom:
            linkedFrom != null && session.document.pageAt(linkedFrom) == target
            ? () => null
            : null,
      ),
    );
    _unsaved = (
      position: positionForFraction(
        session.document.fractionOf(target),
        session.pageCount,
        session.item.runTimeTicks,
      ),
      last: math.max(target, through ?? target) >= session.pageCount - 1,
    );
    _saveTimer?.cancel();
    _saveTimer = Timer(saveDelay, () => unawaited(_save()));
  }

  void next() => goTo((_session?.page ?? 0) + 1);
  void previous() => goTo((_session?.page ?? 0) - 1);

  /// Saves the place now. The screen awaits this when leaving, so the page
  /// it returns to shows the new progress.
  Future<void> close() async {
    _saveTimer?.cancel();
    await _save();
    if (ref.mounted) ref.read(watchStateProvider.notifier).changed();
  }

  Future<void> _save() async {
    final unsaved = _unsaved;
    if (unsaved == null) return;
    _unsaved = null;
    final markRead = unsaved.last && !_markedRead;
    try {
      await _books.savePosition(itemId, unsaved.position);
      // Read only once the server says so: a failure tries again.
      if (markRead) {
        await _books.setRead(itemId, read: true);
        _markedRead = true;
      }
      // The server is there: this book's older place is moot, and the
      // others kept while it was away can go now.
      _pending
        ..remove(itemId)
        ..flush();
    } on Failure catch (e) {
      log.warning('reader', 'could not save the place; kept for later', e);
      _pending.add(itemId, (position: unsaved.position, read: markRead));
    }
  }

  void _release() {
    _saveTimer?.cancel();
    final document = _session?.document;
    // Left without close() (the window): still save, then let go.
    unawaited(() async {
      await _save();
      await document?.dispose();
    }());
  }
}
