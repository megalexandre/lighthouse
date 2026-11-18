import 'package:material_ui/material_ui.dart';

import '../../../api/models/base_item_dto.dart';
import '../../../core/failure.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/ticks.dart';
import '../../library/presentation/item_card.dart';
import 'player_screen.dart';

// What the player shows instead of, or over, the picture: while loading or
// failed, music's cover, and the notice when the stream broke off.

/// Loading or failed: the message in the middle, and a way back.
class PlayerMessage extends StatelessWidget {
  const PlayerMessage({super.key, required this.onBack, required this.child});

  final VoidCallback onBack;
  final Widget child;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Center(child: child),
      SafeArea(
        child: IconButton(
          key: PlayerScreen.backButton,
          color: context.tokens.osdInk,
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
      ),
    ],
  );
}

/// Music: the album cover, with the track, artist and album under it.
class AudioCover extends StatelessWidget {
  const AudioCover({super.key, required this.item});

  final BaseItemDto item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = (MediaQuery.sizeOf(context).shortestSide * 0.5).clamp(
      160.0,
      480.0,
    );
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            key: PlayerScreen.cover,
            dimension: size,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(context.tokens.radiusMd),
              child: ItemImage(item: item, width: size),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            item.name,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: context.tokens.osdInk,
            ),
          ),
          if ([?item.albumArtist, ?item.album] case final parts
              when parts.isNotEmpty)
            Text(
              parts.join(' · '),
              style: theme.textTheme.titleMedium?.copyWith(
                color: context.tokens.osdInkMuted,
              ),
            ),
        ],
      ),
    );
  }
}

/// The stream broke off before the end (connection lost): where it was,
/// and Resume from there once the server is reachable again.
class InterruptedNotice extends StatefulWidget {
  const InterruptedNotice({
    super.key,
    required this.at,
    required this.onResume,
    required this.onBack,
  });

  final Duration at;
  final Future<void> Function() onResume;
  final VoidCallback onBack;

  @override
  State<InterruptedNotice> createState() => _InterruptedNoticeState();
}

class _InterruptedNoticeState extends State<InterruptedNotice> {
  bool _resuming = false;
  String? _error;

  Future<void> _resume() async {
    setState(() {
      _resuming = true;
      _error = null;
    });
    try {
      await widget.onResume();
    } on Failure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _resuming = false);
    }
  }

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: context.tokens.osdScrim,
    child: Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off, size: 40),
              const SizedBox(height: 12),
              Text(
                'Playback stopped at ${formatPosition(widget.at)}: the '
                'connection to the server was lost.',
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: widget.onBack,
                    child: const Text('Back'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    key: PlayerScreen.resumeAfterBreak,
                    onPressed: _resuming ? null : _resume,
                    icon: const Icon(Icons.play_arrow),
                    label: Text('Resume from ${formatPosition(widget.at)}'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
