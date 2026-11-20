import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../api/models/base_item_dto.dart';
import '../../../../api/models/media_stream.dart';
import '../../../../api/models/playback_report.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ticks.dart';
import '../../../../core/touch.dart';
import '../../../../core/window_size.dart';
import '../../../../l10n/l10n.dart';
import '../../../../widgets/media_badge.dart';
import '../../../library/presentation/item_card.dart';
import '../../application/player_controller.dart';
import '../../application/trickplay.dart';
import '../../data/player_engine.dart';
import '../player_screen.dart';
import 'control_button.dart';
import 'seek_bar.dart';
import 'settings_menu.dart';

/// The on-screen controls (the design system's VideoPlayer): the title
/// over a gradient at the top; at the bottom, over another, the seek bar
/// and a row of buttons. Paused, a big play button in the middle.
class PlayerOsd extends StatelessWidget {
  const PlayerOsd({
    super.key,
    required this.session,
    required this.controller,
    required this.chapters,
    required this.thumbnails,
    required this.fullscreen,
    required this.onFullscreen,
    required this.onNext,
    required this.onPrevious,
    required this.onSeekBy,
    required this.onBack,
    required this.onInteract,
    required this.onMenu,
    required this.showCenterPlay,
  });

  final PlayerSession session;
  final PlayerController controller;
  final List<SeekChapter> chapters;
  final TrickplayThumbnails? thumbnails;
  final bool fullscreen;
  final VoidCallback onFullscreen;
  final Future<void> Function()? onNext;
  final Future<void> Function() onPrevious;
  final Future<void> Function(Duration) onSeekBy;
  final VoidCallback onBack;
  final VoidCallback onInteract;
  final void Function(SettingsPage page) onMenu;
  final bool showCenterPlay;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final size = WindowSize.of(context);
    final narrow = !size.atLeast(WindowSize.expanded);
    final margin = narrow ? tokens.space(4) : tokens.space(6);
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(
          children: [
            _TitleBar(item: session.item, margin: margin, onBack: onBack),
            const Spacer(),
            _ControlBar(
              osd: this,
              margin: margin,
              narrow: narrow,
              compact: size == WindowSize.compact,
            ),
          ],
        ),
        if (showCenterPlay)
          _CenterPlay(engine: session.engine, onInteract: onInteract),
      ],
    );
  }
}

/// Do [action], keeping the controls up.
VoidCallback _keepingUp(
  FutureOr<void> Function() action,
  VoidCallback onInteract,
) => () {
  unawaited(Future.sync(action));
  onInteract();
};

/// Top: back and title, over a gradient so they read on any frame. An
/// episode shows its series, with "S1:E3 · Name" under it.
class _TitleBar extends StatelessWidget {
  const _TitleBar({
    required this.item,
    required this.margin,
    required this.onBack,
  });

  final BaseItemDto item;
  final double margin;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final (title, subtitle) = switch (item) {
      BaseItemDto(type: BaseItemKind.episode, :final seriesName?) => (
        seriesName,
        [?episodeNumber(item, context.l10n), item.name].join(' · '),
      ),
      _ => (item.name, cardSubtitle(item, context.l10n)),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: tokens.scrim(from: Alignment.topCenter),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            margin - 8,
            tokens.space(3),
            margin,
            tokens.space(8),
          ),
          child: Row(
            children: [
              ControlButton(
                key: PlayerScreen.backButton,
                icon: Icons.arrow_back,
                label: context.l10n.back,
                shortcut: 'Esc',
                onPressed: onBack,
              ),
              SizedBox(width: tokens.space(2)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: tokens.osdInk,
                      ),
                    ),
                    if (subtitle != null && subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.osdInkMuted,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bottom: the seek bar, and under it the transport buttons and time on
/// the left, the volume, badges and menus on the right.
class _ControlBar extends StatelessWidget {
  const _ControlBar({
    required this.osd,
    required this.margin,
    required this.narrow,
    required this.compact,
  });

  final PlayerOsd osd;
  final double margin;
  final bool narrow;

  /// A phone upright: the buttons in two rows, the transport on its own.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final engine = osd.session.engine;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: tokens.scrim(from: Alignment.bottomCenter),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            margin,
            tokens.space(12),
            margin,
            tokens.space(3),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeekBar(
                key: PlayerScreen.seekBar,
                engine: engine,
                chapters: osd.chapters,
                thumbnails: osd.thumbnails,
                onInteract: osd.onInteract,
              ),
              SizedBox(height: tokens.space(2)),
              if (compact) ...[
                _Transport(osd: osd),
                SizedBox(height: tokens.space(1)),
              ],
              Row(
                children: [
                  if (!compact) ...[
                    _Transport(osd: osd),
                    SizedBox(width: tokens.space(2)),
                  ],
                  _Time(engine: engine, showLength: !narrow),
                  const Spacer(),
                  // A phone's volume is its keys'.
                  if (!isTouch(context))
                    _Volume(
                      engine: engine,
                      controller: osd.controller,
                      onInteract: osd.onInteract,
                      slider: !narrow,
                    ),
                  // No room for the quality badges on a phone.
                  _Extras(osd: osd, badges: !compact),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Previous, −10 s, play / pause, +10 s, and Next when there is one.
class _Transport extends StatelessWidget {
  const _Transport({required this.osd});

  final PlayerOsd osd;

  @override
  Widget build(BuildContext context) {
    final engine = osd.session.engine;
    VoidCallback tap(FutureOr<void> Function() action) =>
        _keepingUp(action, osd.onInteract);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ControlButton(
          key: PlayerScreen.previousButton,
          icon: Icons.skip_previous,
          label: context.l10n.previous,
          shortcut: 'Shift+P',
          onPressed: tap(osd.onPrevious),
        ),
        ControlButton(
          key: PlayerScreen.seekBackButton,
          icon: Icons.replay_10,
          label: context.l10n.back10,
          shortcut: '←',
          onPressed: tap(() => osd.onSeekBy(const Duration(seconds: -10))),
        ),
        StreamBuilder<bool>(
          stream: engine.playingStream,
          initialData: engine.playing,
          builder: (_, snap) {
            final playing = snap.data ?? false;
            return ControlButton(
              key: PlayerScreen.playPauseButton,
              icon: playing ? Icons.pause : Icons.play_arrow,
              label: playing ? context.l10n.pause : context.l10n.play,
              shortcut: context.l10n.keySpace,
              size: 52,
              iconSize: 32,
              onPressed: tap(engine.playOrPause),
            );
          },
        ),
        ControlButton(
          key: PlayerScreen.seekForwardButton,
          icon: Icons.forward_10,
          label: context.l10n.forward10,
          shortcut: '→',
          onPressed: tap(() => osd.onSeekBy(const Duration(seconds: 10))),
        ),
        if (osd.onNext case final next?)
          ControlButton(
            key: PlayerScreen.nextButton,
            icon: Icons.skip_next,
            label: context.l10n.next,
            shortcut: 'Shift+N',
            onPressed: tap(next),
          ),
      ],
    );
  }
}

/// The quality badges, then subtitles (when the item has some), the
/// settings panel and full screen.
class _Extras extends StatelessWidget {
  const _Extras({required this.osd, required this.badges});

  final PlayerOsd osd;
  final bool badges;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final session = osd.session;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (badges)
          for (final b in qualityBadges(session, context.l10n))
            Padding(
              padding: EdgeInsets.only(left: tokens.space(1)),
              child: MediaBadge(b, onVideo: true),
            ),
        SizedBox(width: tokens.space(1)),
        if (session.plan.subtitleStreams.isNotEmpty)
          ControlButton(
            key: PlayerScreen.subtitleMenu,
            icon: Icons.subtitles,
            label: context.l10n.subtitles,
            shortcut: 'S',
            active: session.subtitleStreamIndex != null,
            onPressed: () => osd.onMenu(SettingsPage.subtitles),
          ),
        ControlButton(
          key: PlayerScreen.settingsButton,
          icon: Icons.settings,
          label: context.l10n.settings,
          onPressed: () => osd.onMenu(SettingsPage.root),
        ),
        ControlButton(
          key: PlayerScreen.fullscreenButton,
          icon: osd.fullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
          label: osd.fullscreen
              ? context.l10n.exitFullScreen
              : context.l10n.fullScreen,
          shortcut: 'F',
          onPressed: _keepingUp(osd.onFullscreen, osd.onInteract),
        ),
      ],
    );
  }
}

/// Paused: the big play button in the middle.
class _CenterPlay extends StatelessWidget {
  const _CenterPlay({required this.engine, required this.onInteract});

  final PlayerEngine engine;
  final VoidCallback onInteract;

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
    stream: engine.playingStream,
    initialData: engine.playing,
    builder: (_, snap) => (snap.data ?? false)
        ? const SizedBox.shrink()
        : Center(
            child: CenterPlayButton(
              key: PlayerScreen.centerPlayButton,
              onPressed: _keepingUp(engine.play, onInteract),
            ),
          ),
  );
}

/// What is shown over the video about the stream: its resolution, and
/// TRANSCODING when the server converts it.
List<String> qualityBadges(PlayerSession session, AppLocalizations l10n) {
  final video = session.plan.source.mediaStreams
      .where((s) => s.type == MediaStreamType.video)
      .firstOrNull;
  final height = video?.height ?? 0;
  return [
    if (height >= 2000)
      '4K'
    else if (height >= 1000)
      '1080P'
    else if (height >= 700)
      '720P',
    if (session.plan.method == PlayMethod.transcode) l10n.transcoding,
  ];
}

/// "0:01 / 1:52:07": elapsed and length, in fixed-width digits so the row
/// does not jiggle as it runs.
class _Time extends StatelessWidget {
  const _Time({required this.engine, required this.showLength});

  final PlayerEngine engine;
  final bool showLength;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final style = tokens.timecode.copyWith(color: tokens.osdInk);
    return StreamBuilder<Duration>(
      stream: engine.durationStream,
      initialData: engine.duration,
      builder: (_, durationSnap) => StreamBuilder<Duration>(
        stream: engine.positionStream,
        initialData: engine.position,
        builder: (_, positionSnap) {
          final duration = durationSnap.data ?? Duration.zero;
          final position = positionSnap.data ?? Duration.zero;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatPosition(position > duration ? duration : position),
                key: PlayerScreen.positionText,
                style: style,
              ),
              if (showLength)
                Text(
                  ' / ${formatPosition(duration)}',
                  style: style.copyWith(color: tokens.osdInkMuted),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Mute button and a short volume bar (the bar left out on narrow
/// windows).
class _Volume extends StatelessWidget {
  const _Volume({
    required this.engine,
    required this.controller,
    required this.onInteract,
    required this.slider,
  });

  final PlayerEngine engine;
  final PlayerController controller;
  final VoidCallback onInteract;
  final bool slider;

  @override
  Widget build(BuildContext context) => StreamBuilder<bool>(
    stream: engine.mutedStream,
    initialData: engine.muted,
    builder: (_, mutedSnap) => StreamBuilder<double>(
      stream: engine.volumeStream,
      initialData: engine.volume,
      builder: (_, volumeSnap) {
        final muted = mutedSnap.data ?? false;
        final volume = muted ? 0.0 : (volumeSnap.data ?? 100).clamp(0, 100);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ControlButton(
              key: PlayerScreen.muteButton,
              icon: muted || volume == 0
                  ? Icons.volume_off
                  : (volume < 50 ? Icons.volume_down : Icons.volume_up),
              label: muted ? context.l10n.unmute : context.l10n.mute,
              shortcut: 'M',
              active: false,
              onPressed: () {
                unawaited(controller.toggleMute());
                onInteract();
              },
            ),
            if (slider)
              SizedBox(
                width: 100,
                child: Slider(
                  key: PlayerScreen.volumeSlider,
                  max: 100,
                  value: volume.toDouble(),
                  onChanged: (v) {
                    unawaited(controller.setVolume(v));
                    onInteract();
                  },
                ),
              ),
          ],
        );
      },
    ),
  );
}
