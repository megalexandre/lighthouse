import 'package:material_ui/material_ui.dart';

import '../core/theme/app_tokens.dart';
import 'focus_ring.dart';

/// The design system's labelled button (Lanterna "Button"): 44 px high,
/// medium radius, the label in the button style, an optional 20 px icon
/// on its left.
///
/// - [AppButtonKind.primary]: the accent; one per screen (Play, Resume).
/// - [AppButtonKind.secondary]: a raised surface (Start over).
/// - [AppButtonKind.ghost]: no surface until hovered.
///
/// Disabled: 38 % opacity. Focus: the [FocusRing].
enum AppButtonKind { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.kind = AppButtonKind.primary,
    this.autofocus = false,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.autofocus = false,
  }) : kind = AppButtonKind.secondary;

  const AppButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.autofocus = false,
  }) : kind = AppButtonKind.ghost;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonKind kind;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tokens = context.tokens;
    final (Color background, Color hovered, Color foreground) = switch (kind) {
      AppButtonKind.primary => (
        scheme.primary,
        scheme.inversePrimary, // accent-hover
        scheme.onPrimary,
      ),
      AppButtonKind.secondary => (
        scheme.surfaceContainerHigh, // bg-300
        Color.alphaBlend(
          scheme.onSurface.withValues(alpha: 0.08),
          scheme.surfaceContainerHigh,
        ),
        scheme.onSurface,
      ),
      AppButtonKind.ghost => (
        Colors.transparent,
        scheme.surfaceContainerHigh,
        scheme.onSurface,
      ),
    };
    Color fade(Color c) => c.withValues(alpha: c.a * 0.38);
    final radius = BorderRadius.circular(tokens.radiusMd);
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(44, 44)),
      fixedSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
      padding: WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: tokens.space(4)),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: radius),
      ),
      textStyle: WidgetStatePropertyAll(Theme.of(context).textTheme.labelLarge),
      iconSize: const WidgetStatePropertyAll(20),
      elevation: const WidgetStatePropertyAll(0),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      backgroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? fade(background)
            : states.contains(WidgetState.hovered) ||
                  states.contains(WidgetState.pressed)
            ? hovered
            : background,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? fade(foreground)
            : foreground,
      ),
      iconColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.disabled)
            ? fade(foreground)
            : foreground,
      ),
    );
    final text = Text(label);
    final button = icon == null
        ? TextButton(
            style: style,
            autofocus: autofocus,
            onPressed: onPressed,
            child: text,
          )
        : TextButton.icon(
            style: style,
            autofocus: autofocus,
            onPressed: onPressed,
            icon: Icon(icon),
            label: text,
          );
    return FocusRing(borderRadius: radius, child: button);
  }
}

/// A round 44 px icon button on a raised surface (Lanterna: Mark as
/// watched, Favourite, More). [selected] shows [selectedIcon] in
/// [selectedColor] (default: the accent).
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.selected = false,
    this.selectedIcon,
    this.selectedColor,
  });

  final IconData icon;
  final IconData? selectedIcon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool selected;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final surface = scheme.surfaceContainerHigh;
    final pill = BorderRadius.circular(context.tokens.radiusPill);
    return FocusRing(
      borderRadius: pill,
      child: IconButton(
        tooltip: tooltip,
        isSelected: selected,
        onPressed: onPressed,
        icon: Icon(icon),
        selectedIcon: Icon(selectedIcon ?? icon),
        style: ButtonStyle(
          fixedSize: const WidgetStatePropertyAll(Size.square(44)),
          minimumSize: const WidgetStatePropertyAll(Size.square(44)),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: pill),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? surface.withValues(alpha: 0.38)
                : states.contains(WidgetState.hovered)
                ? Color.alphaBlend(
                    scheme.onSurface.withValues(alpha: 0.08),
                    surface,
                  )
                : surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? scheme.onSurface.withValues(alpha: 0.38)
                : states.contains(WidgetState.selected)
                ? selectedColor ?? scheme.primary
                : scheme.onSurface,
          ),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    );
  }
}
