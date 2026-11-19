import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../api/models/playback_report.dart';
import '../../../core/failure.dart';
import '../../../core/log.dart';
import '../data/playback_repository.dart';

/// Stop reports that could not reach the server (it was down). They hold
/// resume points, so they are kept and sent when it is back.
final pendingReportsProvider =
    NotifierProvider<PendingReports, List<PlaybackStopInfo>>(
      PendingReports.new,
    );

class PendingReports extends Notifier<List<PlaybackStopInfo>> {
  @override
  List<PlaybackStopInfo> build() => const [];

  void add(PlaybackStopInfo report) {
    // One per item: a later stop of the same item replaces it.
    state = [
      for (final r in state)
        if (r.itemId != report.itemId) r,
      report,
    ];
  }

  /// Sends them all; those that fail again stay.
  void flush() {
    final reports = state;
    if (reports.isEmpty) return;
    state = const [];
    final repository = ref.read(playbackRepositoryProvider);
    for (final report in reports) {
      unawaited(() async {
        try {
          await repository.reportStopped(report);
          log.info('player', 'sent a stop report kept while offline');
        } on Failure catch (e) {
          log.warning('player', 'kept stop report failed again', e);
          if (ref.mounted) add(report);
        }
      }());
    }
  }
}
