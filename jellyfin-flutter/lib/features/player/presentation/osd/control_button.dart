import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
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
        tooltip: shortcut == null ? label : '$label ($shortcut)',
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
        tooltip: 'Play (Space)',
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
