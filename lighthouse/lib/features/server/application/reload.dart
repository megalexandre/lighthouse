import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../library/application/library_providers.dart';
import '../../player/application/pending_reports.dart';
import '../../player/application/play_queue.dart';
import '../../reader/application/pending_reading.dart';
import '../../search/presentation/search_screen.dart';
import '../../settings/application/settings_providers.dart';

/// The server is back: everything shown may have failed or be stale, so it
/// loads again, and playback reports and reading places that could not be
/// sent go now.
void reloadAfterOutage(Ref ref) {
  ref
    ..invalidate(userViewsProvider)
    ..invalidate(resumeProvider)
    ..invalidate(resumeBooksProvider)
    ..invalidate(nextUpProvider)
    ..invalidate(latestProvider)
    ..invalidate(itemProvider)
    ..invalidate(libraryControllerProvider)
    ..invalidate(seasonsProvider)
    ..invalidate(episodesProvider)
    ..invalidate(tracksProvider)
    ..invalidate(searchResultsProvider)
    ..invalidate(playNeighborsProvider)
    ..invalidate(userConfigurationProvider)
    ..invalidate(languagesProvider);
  ref.read(pendingReportsProvider.notifier).flush();
  ref.read(pendingReadingProvider.notifier).flush();
}
