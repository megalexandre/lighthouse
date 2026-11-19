import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../l10n/l10n.dart';

class HeroArrow extends StatelessWidget {
  const HeroArrow({
    super.key,
    required this.buttonKey,
    required this.forward,
    required this.onTap,
  });

  /// On the button itself (the arrow's area is the carousel's height).
  final Key buttonKey;
  final bool forward;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
    alignment: forward ? Alignment.centerRight : Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: IconButton(
        key: buttonKey,
        tooltip: forward ? context.l10n.next : context.l10n.previous,
        onPressed: onTap,
        iconSize: 44,
        color: context.tokens.osdInk,
        icon: Icon(forward ? Icons.chevron_right : Icons.chevron_left),
        style: const ButtonStyle(
          fixedSize: WidgetStatePropertyAll(Size(56, 96)),
          overlayColor: WidgetStatePropertyAll(Colors.transparent),
        ),
      ),
    ),
  );
}

class HeroDot extends StatelessWidget {
  const HeroDot({super.key, required this.on, required this.onTap});

  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: on,
    label: context.l10n.slide,
    child: GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: on ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: on
                ? context.tokens.osdInk
                : context.tokens.osdInk.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    ),
  );
}
