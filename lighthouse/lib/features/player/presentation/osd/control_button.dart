import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../l10n/l10n.dart';
import '../../../../widgets/focus_ring.dart';

/// A round icon button over the video (the design system's ControlButton):
/// 44 px, the icon in `osd-ink`; hover `osd-hover`; focus the ring in
/// `osd-accent`; [active] (subtitles on) the icon in `osd-accent`;
/// disabled 38 %. The tooltip names the key: "Subtitles (S)".
class ControlButton extends StatelessWidget {
  const ControlButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.shortcut,
    this.active = false,
    this.size = 44,
    this.iconSize = 24,
  });

  final IconData icon;

  /// What it does ("Subtitles"), for the tooltip and screen readers.
  final String label;

  /// The key that does the same ("S"), shown in the tooltip.
  final String? shortcut;
  final VoidCallback? onPressed;
  final bool active;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final pill = BorderRadius.circular(tokens.radiusPill);
    final ink = active ? tokens.osdAccent : tokens.osdInk;
    return FocusRing(
      borderRadius: pill,
      color: tokens.osdAccent,
      child: IconButton(
        tooltip: shortcut == null
            ? label
            : context.l10n.withShortcut(label, shortcut!),
        onPressed: onPressed,
        iconSize: iconSize,
        icon: Icon(icon),
        style: ButtonStyle(
          fixedSize: WidgetStatePropertyAll(Size.square(size)),
          minimumSize: WidgetStatePropertyAll(Size.square(size)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: pill),
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? ink.withValues(alpha: 0.38)
                : ink,
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                !states.contains(WidgetState.disabled) &&
                    (states.contains(WidgetState.hovered) ||
                        states.contains(WidgetState.pressed))
                ? tokens.osdHover
                : Colors.transparent,
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    );
  }
}

/// Beside the big play button, on a paused video: −10 s and +10 s, a
/// 56 px disc in `osd-surface` (`osd-hover` under the mouse) so they read
/// over any picture, the icon in `osd-ink`.
class CenterSeekButton extends StatelessWidget {
  const CenterSeekButton({
    super.key,
    required this.icon,
    required this.label,
    required this.shortcut,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final String shortcut;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final pill = BorderRadius.circular(tokens.radiusPill);
    return FocusRing(
      borderRadius: pill,
      color: tokens.osdAccent,
      child: IconButton(
        tooltip: context.l10n.withShortcut(label, shortcut),
        onPressed: onPressed,
        iconSize: 32,
        icon: Icon(icon),
        style: ButtonStyle(
          fixedSize: const WidgetStatePropertyAll(Size.square(56)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: pill),
          ),
          foregroundColor: WidgetStatePropertyAll(tokens.osdInk),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) =>
                states.contains(WidgetState.hovered) ||
                    states.contains(WidgetState.pressed)
                ? tokens.osdHover
                : tokens.osdSurface,
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    );
  }
}

/// The big play button in the middle of a paused video: a 72 px disc in
/// `osd-accent`.
class CenterPlayButton extends StatelessWidget {
  const CenterPlayButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final pill = BorderRadius.circular(tokens.radiusPill);
    return FocusRing(
      borderRadius: pill,
      color: tokens.osdInk,
      child: IconButton(
        tooltip: context.l10n.withShortcut(
          context.l10n.play,
          context.l10n.keySpace,
        ),
        onPressed: onPressed,
        iconSize: 40,
        icon: const Icon(Icons.play_arrow),
        style: ButtonStyle(
          fixedSize: const WidgetStatePropertyAll(Size.square(72)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: pill),
          ),
          foregroundColor: WidgetStatePropertyAll(tokens.osdAccentInk),
          backgroundColor: WidgetStatePropertyAll(tokens.osdAccent),
          overlayColor: WidgetStatePropertyAll(
            tokens.osdAccentInk.withValues(alpha: 0.08),
          ),
        ),
      ),
    );
  }
}
