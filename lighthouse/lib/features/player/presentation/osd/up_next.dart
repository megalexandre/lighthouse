import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../api/models/base_item_dto.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ticks.dart';
import '../../../../l10n/l10n.dart';
import '../../../../widgets/app_button.dart';
import '../../../library/presentation/item_card.dart';

/// The "Up next" card (the design system's UpNext), bottom right in the
/// last seconds of an episode: the next one's picture with a countdown
/// ring, its name, and Watch now / Hide. When the countdown ends the next
/// episode starts (the player does that when this one ends: pausing
/// pauses the countdown too).
class UpNextCard extends StatelessWidget {
  const UpNextCard({
    super.key,
    required this.next,
    required this.remaining,
    required this.onWatchNow,
    required this.onHide,
  });

  static const card = Key('player.upNext');
  static const watchNowButton = Key('player.upNext.watchNow');
  static const hideButton = Key('player.upNext.hide');

  /// It shows for the last [countdown] of an episode.
  static const countdown = Duration(seconds: 10);
  static const width = 360.0;

  final BaseItemDto next;

  /// Until this one ends (and the next starts).
  final Duration remaining;
  final VoidCallback onWatchNow;
  final VoidCallback onHide;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final seconds = (remaining.inMilliseconds / 1000).ceil().clamp(0, 99);
    final fraction = (remaining.inMilliseconds / countdown.inMilliseconds)
        .clamp(0.0, 1.0);
    final title = [?episodeNumber(next, context.l10n), next.name].join(' · ');
    final length = next.runTimeTicks == null
        ? null
        : ticksToDuration(next.runTimeTicks!);
    final endsAt = length == null
        ? null
        : TimeOfDay.fromDateTime(DateTime.now().add(remaining + length));
    final meta = [
      if (length != null) formatRuntime(length, context.l10n),
      if (endsAt != null) context.l10n.endsAt(endsAt.format(context)),
    ].join(' · ');

    return Container(
      key: card,
      width: width,
      padding: EdgeInsets.all(tokens.space(4)),
      decoration: BoxDecoration(
        color: tokens.osdSurface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        boxShadow: tokens.shadowMenu,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Thumbnail(next: next, seconds: seconds, fraction: fraction),
              SizedBox(width: tokens.space(4)),
              Expanded(
                child: _Details(seconds: seconds, title: title, meta: meta),
              ),
            ],
          ),
          SizedBox(height: tokens.space(3)),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  key: watchNowButton,
                  icon: Icons.play_arrow,
                  label: context.l10n.watchNow,
                  autofocus: true,
                  onPressed: onWatchNow,
                ),
              ),
              SizedBox(width: tokens.space(2)),
              AppButton.ghost(
                key: hideButton,
                label: context.l10n.hide,
                onPressed: onHide,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The next episode's picture, with the countdown ring over it.
class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.next,
    required this.seconds,
    required this.fraction,
  });

  final BaseItemDto next;
  final int seconds;

  /// Of the countdown left: the ring's arc.
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SizedBox(
      width: 136,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ItemImage(item: next, width: 136),
              Center(
                child: SizedBox.square(
                  dimension: 40,
                  child: CustomPaint(
                    painter: _RingPainter(
                      fraction: fraction,
                      shade: tokens.mediaShade.withValues(alpha: 0.5),
                      track: tokens.osdTrack,
                      accent: tokens.osdAccent,
                    ),
                    child: Center(
                      child: Text(
                        '$seconds',
                        style: tokens.timecode.copyWith(color: tokens.osdInk),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "UP NEXT · IN 6 S", the next episode's name, and its length and when
/// it would end.
class _Details extends StatelessWidget {
  const _Details({
    required this.seconds,
    required this.title,
    required this.meta,
  });

  final int seconds;
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.upNextIn(seconds),
          style: tokens.overline.copyWith(color: tokens.osdInkMuted),
        ),
        const SizedBox(height: 2),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleMedium?.copyWith(color: tokens.osdInk),
        ),
        if (meta.isNotEmpty)
          Text(
            meta,
            style: theme.textTheme.bodySmall?.copyWith(
              color: tokens.osdInkMuted,
            ),
          ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.shade,
    required this.track,
    required this.accent,
  });

  final double fraction;

  /// Behind the number, so it reads on any picture.
  final Color shade;
  final Color track;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 1.5;
    canvas
      ..drawCircle(center, radius, Paint()..color = shade)
      ..drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = track,
      )
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        2 * math.pi * fraction,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..color = accent,
      );
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}
