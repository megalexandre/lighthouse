import 'package:material_ui/material_ui.dart';

import '../core/theme/app_tokens.dart';

/// A short technical label (Lanterna "Badge"): 4K, HDR, 5.1, CC. Overline
/// type, small radius, a 1 px border.
///
/// - In the library: muted text, `line` border.
/// - Over the video ([onVideo]): `osd-ink` text, `osd-ink-muted` border.
/// - [highlight] (NEW): accent fill, no border; one per card at most.
class MediaBadge extends StatelessWidget {
  const MediaBadge(
    this.text, {
    super.key,
    this.highlight = false,
    this.onVideo = false,
  });

  final String text;
  final bool highlight;
  final bool onVideo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    final (Color? fill, Color? border, Color ink) = highlight
        ? (scheme.primary, null, scheme.onPrimary)
        : onVideo
        ? (null, tokens.osdInkMuted, tokens.osdInk)
        : (null, scheme.outline, scheme.onSurfaceVariant);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        border: border == null ? null : Border.all(color: border),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: tokens.space(2) - (border == null ? 0 : 1),
          vertical: border == null ? 2 : 1,
        ),
        child: Text(
          text.toUpperCase(),
          style: tokens.overline.copyWith(color: ink),
        ),
      ),
    );
  }
}
