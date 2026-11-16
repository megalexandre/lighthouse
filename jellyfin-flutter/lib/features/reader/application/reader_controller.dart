import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../library/application/library_providers.dart';
import '../../library/data/library_repository.dart';
import '../data/book_document.dart';
import '../data/book_repository.dart';
import '../data/reading_position.dart';

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
  });

  final BaseItemDto item;
  final BookDocument document;
  final int page;

  int get pageCount => document.pageCount;
  bool get onLastPage => page == pageCount - 1;
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
  int? _unsavedPage;
  bool _markedRead = false;
  ReaderSession? _session;
  late final BookRepository _books = ref.read(bookRepositoryProvider);

  @override
  Future<ReaderSession> build() async {
    ref.onDispose(_release);
    final item = await ref.read(libraryRepositoryProvider).item(itemId);
    final file = await _books.file(item);
    final document = await ref.read(bookOpenerProvider)(file);
    if (!ref.mounted) {
      await document.dispose();
      throw const NotReadable('a book closed while opening');
    }
    final data = item.userData;
    final start = (data?.played ?? false)
        ? 0
        : pageForPosition(
            data?.playbackPositionTicks ?? 0,
            document.pageCount,
            item.runTimeTicks,
          );
    log.info(
      'reader',
      '"${item.name}": ${document.pageCount} pages, opened at ${start + 1}',
    );
    return _session = ReaderSession(
      item: item,
      document: document,
      page: start,
    );
  }

  /// Shows [page] (0-based, clamped to the book).
  void goTo(int page) {
    final session = _session;
    if (session == null) return;
    final target = page.clamp(0, session.pageCount - 1);
    if (target == session.page) return;
    _session = ReaderSession(
      item: session.item,
      document: session.document,
      page: target,
    );
    state = AsyncData(_session!);
    _unsavedPage = target;
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
    if (!ref.mounted) return;
    ref
      ..invalidate(itemProvider(itemId))
      ..invalidate(resumeBooksProvider);
  }

  Future<void> _save() async {
    final session = _session;
    final page = _unsavedPage;
    if (session == null || page == null) return;
    _unsavedPage = null;
    try {
      await _books.savePosition(
        itemId,
        positionForPage(page, session.pageCount, session.item.runTimeTicks),
      );
      if (page == session.pageCount - 1 && !_markedRead) {
        _markedRead = true;
        await _books.setRead(itemId, read: true);
      }
    } on Failure catch (e) {
      log.warning('reader', 'could not save the place', e);
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
