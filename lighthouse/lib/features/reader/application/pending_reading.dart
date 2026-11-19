import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../../auth/application/auth_controller.dart';
import '../data/book_repository.dart';

/// A place in a book the server has not heard of yet ([read]: the last
/// page was reached, so the book is to be marked read too).
typedef PendingPlace = ({int position, bool read});

/// Places in books that could not reach the server (it was away): kept,
/// and sent when it is back (reloadAfterOutage) or when another save gets
/// through. Reopening such a book opens it there, not where the server
/// last heard.
///
/// They belong to the user who read: a new session drops them.
final pendingReadingProvider =
    NotifierProvider<PendingReading, Map<String, PendingPlace>>(
      PendingReading.new,
    );

class PendingReading extends Notifier<Map<String, PendingPlace>> {
  @override
  Map<String, PendingPlace> build() {
    ref.watch(authControllerProvider.select((auth) => auth.value?.session));
    return const {};
  }

  /// Keeps [place] for [itemId], over an older one (a book once read
  /// stays to be marked read).
  void add(String itemId, PendingPlace place) {
    // Gone (the app closing, another session): nowhere to keep it.
    if (!ref.mounted) return;
    final read = place.read || (state[itemId]?.read ?? false);
    state = {...state, itemId: (position: place.position, read: read)};
  }

  /// [itemId]'s place reached the server.
  void remove(String itemId) {
    if (!ref.mounted || !state.containsKey(itemId)) return;
    state = {
      for (final e in state.entries)
        if (e.key != itemId) e.key: e.value,
    };
  }

  /// Sends them all; those that fail again stay (unless the reader kept a
  /// newer place for the book meanwhile).
  void flush() {
    if (!ref.mounted) return;
    final places = state;
    if (places.isEmpty) return;
    state = const {};
    final books = ref.read(bookRepositoryProvider);
    for (final MapEntry(key: itemId, value: place) in places.entries) {
      unawaited(() async {
        try {
          await books.savePosition(itemId, place.position);
          if (place.read) await books.setRead(itemId, read: true);
          log.info('reader', 'sent a place kept while offline');
        } on Failure catch (e) {
          log.warning('reader', 'kept place failed again', e);
          if (ref.mounted && !state.containsKey(itemId)) add(itemId, place);
        }
      }());
    }
  }
}
