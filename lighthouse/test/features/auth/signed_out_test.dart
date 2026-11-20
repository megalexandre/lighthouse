import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/playback_report.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/core/storage.dart';
import 'package:lighthouse/features/library/data/library_repository.dart';
import 'package:lighthouse/features/player/data/playback_repository.dart';
import 'package:lighthouse/features/reader/data/book_repository.dart';
import 'package:lighthouse/features/settings/data/settings_repository.dart';

import '../../support/fakes.dart';

// While nobody is signed in the app still builds its screens' providers;
// what they read comes from these. Every call that would need the server
// fails with Unauthorized, which sends the user to sign in.
void main() {
  final movie = TestItems.testMovie;
  const progress = PlaybackProgressInfo(
    itemId: 'movie-1',
    mediaSourceId: 'movie-1',
    positionTicks: 0,
    playMethod: PlayMethod.directPlay,
  );
  const stop = PlaybackStopInfo(
    itemId: 'movie-1',
    mediaSourceId: 'movie-1',
    positionTicks: 0,
  );

  const library = SignedOutLibraryRepository();
  const playback = SignedOutPlaybackRepository();
  const books = SignedOutBookRepository();
  final settings = SignedOutSettingsRepository(MemoryKeyValueStore());

  final calls = <String, Future<Object?> Function()>{
    'library: views': library.views,
    'library: children': () =>
        library.children(movie, startIndex: 0, limit: 10),
    'library: item': () => library.item('movie-1'),
    'library: latest': () => library.latest('view-movies'),
    'library: featured': library.featured,
    'library: resume': library.resume,
    'library: resumeBooks': library.resumeBooks,
    'library: nextUp': library.nextUp,
    'library: nextUpOf': () => library.nextUpOf('series-1'),
    'library: seasons': () => library.seasons('series-1'),
    'library: episodes': () => library.episodes('series-1', 'season-1'),
    'library: seriesEpisodes': () => library.seriesEpisodes('series-1'),
    'library: search': () => library.search('test'),
    'library: tracks': () => library.tracks('album-1'),
    'playback: prepare': () => playback.prepare(movie),
    'playback: reportStart': () => playback.reportStart(progress),
    'playback: reportProgress': () => playback.reportProgress(progress),
    'playback: reportStopped': () => playback.reportStopped(stop),
    'playback: setPlayed': () => playback.setPlayed('movie-1', played: true),
    'playback: trickplayTile': () => playback.trickplayTile(
      'movie-1',
      mediaSourceId: 'movie-1',
      width: 160,
      index: 0,
    ),
    'books: file': () => books.file(TestItems.testComic),
    'books: savePosition': () => books.savePosition('book-comic', 0),
    'books: setRead': () => books.setRead('book-comic', read: true),
    'books: bookmarks': () => books.bookmarks('book-comic'),
    'books: saveBookmarks': () => books.saveBookmarks('book-comic', const []),
    'settings: userConfiguration': settings.userConfiguration,
    'settings: updateUserConfiguration': () =>
        settings.updateUserConfiguration(audioLanguage: 'por'),
    'settings: languages': settings.languages,
  };

  for (final MapEntry(key: name, value: call) in calls.entries) {
    test('$name fails with Unauthorized', () async {
      await expectLater(call(), throwsA(isA<Unauthorized>()));
    });
  }

  test('nothing has a picture', () {
    expect(library.imageUrl(movie, maxWidth: 300), isNull);
    expect(library.backdropUrl(movie, maxWidth: 300), isNull);
  });
}
