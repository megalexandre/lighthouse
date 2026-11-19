import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/failure.dart';
import '../../../core/ticks.dart';
import '../../../l10n/l10n.dart';
import '../../../router.dart';
import '../../../widgets/app_button.dart';
import '../../library/application/library_providers.dart';
import '../../player/data/playback_repository.dart';
import '../../reader/data/book_repository.dart';
import 'item_screen.dart';

/// Play (or Resume + Start over when partly watched), and watched / not.
class PlayButtons extends ConsumerStatefulWidget {
  const PlayButtons({super.key, required this.item});

  final BaseItemDto item;

  @override
  ConsumerState<PlayButtons> createState() => _PlayButtonsState();
}

class _PlayButtonsState extends ConsumerState<PlayButtons> {
  bool _saving = false;

  BaseItemDto get item => widget.item;

  Future<void> _play(Duration start) async {
    await context.push(Routes.play(item.id, start: start));
  }

  Future<void> _toggleWatched(bool played) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(playbackRepositoryProvider)
          .setPlayed(item.id, played: !played);
      ref.read(watchStateProvider.notifier).changed();
    } on Failure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.describe(context.l10n))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = item.userData;
    final played = data?.played ?? false;
    final position = ticksToDuration(data?.playbackPositionTicks ?? 0);
    final resumable = !played && position > Duration.zero;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // One primary button: Resume when there is a place, else Play.
        if (resumable) ...[
          AppButton(
            key: ItemScreen.resumeButton,
            icon: Icons.play_arrow,
            label: context.l10n.resumeFrom(formatPosition(position)),
            onPressed: () => _play(position),
          ),
          AppButton.secondary(
            key: ItemScreen.playButton,
            icon: Icons.replay,
            label: context.l10n.startOver,
            onPressed: () => _play(Duration.zero),
          ),
        ] else
          AppButton(
            key: ItemScreen.playButton,
            icon: Icons.play_arrow,
            label: context.l10n.play,
            onPressed: () => _play(Duration.zero),
          ),
        AppIconButton(
          key: ItemScreen.watchedButton,
          tooltip: played
              ? context.l10n.markUnwatched
              : context.l10n.markWatched,
          selected: played,
          icon: Icons.check,
          onPressed: _saving ? null : () => _toggleWatched(played),
        ),
      ],
    );
  }
}

/// Read (or Continue reading, with how much is read) and read / not.
class ReadButtons extends ConsumerStatefulWidget {
  const ReadButtons({super.key, required this.item});

  final BaseItemDto item;

  @override
  ConsumerState<ReadButtons> createState() => _ReadButtonsState();
}

class _ReadButtonsState extends ConsumerState<ReadButtons> {
  bool _saving = false;

  BaseItemDto get item => widget.item;

  Future<void> _toggleRead(bool read) async {
    setState(() => _saving = true);
    try {
      await ref.read(bookRepositoryProvider).setRead(item.id, read: !read);
      ref.read(watchStateProvider.notifier).changed();
    } on Failure catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.describe(context.l10n))));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = item.userData;
    final read = data?.played ?? false;
    final percent = (data?.playedPercentage ?? 0).round();
    final started = !read && (data?.playbackPositionTicks ?? 0) > 0;
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppButton(
          key: ItemScreen.readButton,
          icon: Icons.auto_stories,
          label: started
              ? context.l10n.continueReadingPercent(percent)
              : context.l10n.read,
          onPressed: () => context.push(Routes.read(item.id)),
        ),
        AppIconButton(
          key: ItemScreen.watchedButton,
          tooltip: read ? context.l10n.markUnread : context.l10n.markRead,
          selected: read,
          icon: Icons.check,
          onPressed: _saving ? null : () => _toggleRead(read),
        ),
      ],
    );
  }
}
