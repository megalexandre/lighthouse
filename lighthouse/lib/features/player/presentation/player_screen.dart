import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/appearance.dart';
import '../../../router.dart';
import '../../../widgets/error_retry.dart';
import '../../settings/application/settings_providers.dart';
import '../application/play_queue.dart';
import '../application/player_carry_over.dart';
import '../application/player_controller.dart';
import 'osd/settings_menu.dart';
import 'player_overlays.dart';
import 'player_view.dart';

/// Full-window playback of one item, with an on-screen display (OSD) that
/// shows on mouse movement and hides after a few seconds of playing.
///
/// Episodes and tracks play on: at the end the next one starts, and
/// Next / Previous step through the series or album. An episode gets a
/// screen of its own; an album plays through in one (the controller goes
/// from song to song by itself). Music shows the
/// album cover, with the OSD always up.
///
/// Keys: see player_keys.dart (Space play/pause, arrows seek and volume,
/// A / L / S audio and subtitles, F11 full screen, Esc back...).
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key, required this.request});

  static const backButton = Key('player.back');
  static const playPauseButton = Key('player.playPause');
  static const seekBar = Key('player.seek');
  static const positionText = Key('player.position');
  static const muteButton = Key('player.mute');
  static const volumeSlider = Key('player.volume');

  /// The settings panel's Audio row (open the panel with [settingsButton]).
  static const audioMenu = SettingsMenu.audioRow;

  /// The bar's subtitles button: opens the panel on the subtitles.
  static const subtitleMenu = Key('player.subtitles');
  static const settingsButton = Key('player.settings');
  static const seekBackButton = Key('player.seekBack');
  static const seekForwardButton = Key('player.seekForward');
  static const centerPlayButton = Key('player.centerPlay');
  static const subtitleOff = Key('player.subtitle.off');
  static const fullscreenButton = Key('player.fullscreen');
  static const nextButton = Key('player.next');
  static const previousButton = Key('player.previous');
  static const cover = Key('player.cover');
  static const resumeAfterBreak = Key('player.resumeAfterBreak');

  /// The side panel (episodes or chapters), its button and its close.
  static const sidePanel = Key('player.panel');
  static const sidePanelButton = Key('player.panelButton');
  static const sidePanelClose = Key('player.panel.close');
  static Key panelSeason(String season) => Key('player.panel.season.$season');
  static Key panelEpisode(String id) => Key('player.panel.episode.$id');
  static Key panelWatched(String id) => Key('player.panel.watched.$id');
  static Key panelChapter(int index) => Key('player.panel.chapter.$index');
  static Key audioItem(int index) => Key('player.audio.$index');
  static Key subtitleItem(int index) => Key('player.subtitle.$index');

  final PlayRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = playerControllerProvider(request);
    final session = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    // An album's songs change in place.
    final itemId = session.value?.item.id ?? request.itemId;
    final neighbors =
        ref.watch(playNeighborsProvider(itemId)).value ?? noNeighbors;
    void goTo(BaseItemDto item) => unawaited(
      item.type == BaseItemKind.audio
          ? ref.read(provider.notifier).playInstead(item)
          : _goTo(context, ref, item),
    );
    // Watched now, so the autoplay preference is known when the item ends.
    final episodesPlayOn =
        ref.watch(userConfigurationProvider).value?.enableNextEpisodeAutoPlay ??
        true;

    // Played to the end: on to the next episode / track, or close.
    ref.listen(provider, (_, now) {
      final session = now.value;
      if (session == null || !session.ended) return;
      // Episodes play on only if the user wants it (a server setting). An
      // album played through before it got here.
      final autoplay =
          session.item.type == BaseItemKind.episode &&
          (ref
                  .read(userConfigurationProvider)
                  .value
                  ?.enableNextEpisodeAutoPlay ??
              true);
      final next = autoplay
          ? ref.read(playNeighborsProvider(request.itemId)).value?.next
          : null;
      unawaited(
        next == null ? _close(context, ref) : _goTo(context, ref, next),
      );
    });

    return _PlayerTheme(
      child: _FullscreenScope(
        // The system's Back is the PlayerView's while playing (it closes
        // the menu first); before that, it just leaves.
        child: Scaffold(
          backgroundColor: Colors.black,
          body: switch (session) {
            AsyncData(value: final session) => PlayerView(
              // Each item its own controls, marks and thumbnails.
              key: ValueKey(session.item.id),
              session: session,
              controller: controller,
              upNext:
                  session.item.type == BaseItemKind.episode && episodesPlayOn
                  ? neighbors.next
                  : null,
              onBack: () => _close(context, ref),
              onNext: neighbors.next == null
                  ? null
                  : () => goTo(neighbors.next!),
              onPrevious: neighbors.previous == null
                  ? null
                  : () => goTo(neighbors.previous!),
              onPlay: goTo,
            ),
            AsyncError(:final error) => PlayerMessage(
              onBack: () => context.pop(),
              child: ErrorRetry(
                error: error,
                onRetry: () => ref.read(provider.notifier).retry(),
              ),
            ),
            _ => PlayerMessage(
              onBack: () => context.pop(),
              child: const CircularProgressIndicator(),
            ),
          },
        ),
      ),
    );
  }

  /// Saves the resume point, then leaves.
  Future<void> _close(BuildContext context, WidgetRef ref) async {
    await ref.read(playerControllerProvider(request).notifier).stop();
    if (context.mounted && context.canPop()) context.pop();
  }

  /// Saves this one's position, then plays [item] in its place (Back still
  /// returns to the page playback started from).
  Future<void> _goTo(
    BuildContext context,
    WidgetRef ref,
    BaseItemDto item,
  ) async {
    await ref.read(playerControllerProvider(request).notifier).stop();
    if (context.mounted) {
      context.pushReplacement(Routes.play(item.id));
    }
  }
}

/// The player is always dark (the design system says so): its menus and
/// dialogs too, whatever the app's mode; its sliders in the OSD's colours.
class _PlayerTheme extends ConsumerWidget {
  const _PlayerTheme({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = ref.watch(appThemeProvider).dark;
    final osd = dark.extension<AppTokens>()!;
    return Theme(
      data: dark.copyWith(
        sliderTheme: dark.sliderTheme.copyWith(
          activeTrackColor: osd.osdAccent,
          thumbColor: osd.osdAccent,
          inactiveTrackColor: osd.osdTrack,
          trackHeight: 4,
        ),
      ),
      child: child,
    );
  }
}

/// Counts this screen among the player screens open, so full screen
/// lasts from one item to the next and ends when the player closes (see
/// playerFullscreenProvider).
class _FullscreenScope extends ConsumerStatefulWidget {
  const _FullscreenScope({required this.child});

  final Widget child;

  @override
  ConsumerState<_FullscreenScope> createState() => _FullscreenScopeState();
}

class _FullscreenScopeState extends ConsumerState<_FullscreenScope> {
  late final PlayerFullscreenNotifier _fullscreen = ref.read(
    playerFullscreenProvider.notifier,
  );

  @override
  void initState() {
    super.initState();
    _fullscreen.enter();
  }

  @override
  void dispose() {
    _fullscreen.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
