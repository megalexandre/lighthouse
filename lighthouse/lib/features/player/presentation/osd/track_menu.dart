import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../l10n/l10n.dart';
import '../../application/player_controller.dart';
import '../../data/tracks.dart';
import '../player_screen.dart';
import 'settings_menu.dart';

/// The settings panel with this item's tracks: audio, subtitles (Off
/// first) and speed. A failed track change says so.
class TrackMenu extends StatelessWidget {
  const TrackMenu({
    super.key,
    required this.menuKey,
    required this.page,
    required this.session,
    required this.controller,
    required this.onClose,
  });

  /// On the menu itself: Esc asks it to go back a level.
  final GlobalKey<SettingsMenuState> menuKey;
  final SettingsPage page;
  final PlayerSession session;
  final PlayerController controller;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final engine = session.engine;
    return SettingsMenu(
      key: menuKey,
      initialPage: page,
      audio: [
        for (final s in session.plan.audioStreams)
          (
            value: s.index,
            label: trackLabel(s, context.l10n),
            detail: trackDetail(s, context.l10n),
            key: PlayerScreen.audioItem(s.index),
          ),
      ],
      selectedAudio: session.audioStreamIndex,
      onAudio: (i) => reportFailure(
        context,
        controller.selectAudio(i),
        context.l10n.trackChangeFailed,
      ),
      subtitles: [
        (
          value: null,
          label: context.l10n.subtitlesOff,
          detail: null,
          key: PlayerScreen.subtitleOff,
        ),
        for (final s in session.plan.subtitleStreams)
          (
            value: s.index,
            label: trackLabel(s, context.l10n),
            detail: trackDetail(s, context.l10n),
            key: PlayerScreen.subtitleItem(s.index),
          ),
      ],
      selectedSubtitle: session.subtitleStreamIndex,
      onSubtitle: (i) => reportFailure(
        context,
        controller.selectSubtitle(i),
        context.l10n.trackChangeFailed,
      ),
      rate: engine.rate,
      onRate: (r) => unawaited(engine.setRate(r)),
      onClose: onClose,
    );
  }
}
