import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart';
import '../data/highlight.dart';
import 'reader_screen.dart';

/// What can be done with the text selected, or with a highlight tapped:
/// write a note, copy, remove the highlight, and a colour for it (picking
/// one is what highlights a selection).
class HighlightMenu extends StatelessWidget {
  const HighlightMenu({
    super.key,
    required this.onColor,
    required this.onNote,
    required this.onCopy,
    this.color,
    this.note = '',
    this.onRemove,
  });

  /// The highlight's colour; null for a selection not highlighted yet.
  final HighlightColor? color;

  /// The highlight's note, shown at the top.
  final String note;
  final ValueChanged<HighlightColor> onColor;
  final VoidCallback onNote;
  final VoidCallback onCopy;

  /// Null for a selection.
  final VoidCallback? onRemove;

  static String colorName(BuildContext context, HighlightColor color) =>
      switch (color) {
        HighlightColor.yellow => context.l10n.highlightYellow,
        HighlightColor.red => context.l10n.highlightRed,
        HighlightColor.blue => context.l10n.highlightBlue,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    Widget action(Key key, IconData icon, String label, VoidCallback onTap) =>
        InkWell(
          key: key,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 16),
                Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
              ],
            ),
          ),
        );
    return Material(
      key: ReaderScreen.highlightMenu,
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      color: theme.colorScheme.surfaceContainer,
      child: SizedBox(
        width: HighlightMenu.width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            if (note.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Text(
                  note,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            action(
              ReaderScreen.noteButton,
              note.isEmpty ? Icons.note_add_outlined : Icons.edit_note,
              note.isEmpty ? l10n.addNote : l10n.editNote,
              onNote,
            ),
            action(
              ReaderScreen.copyButton,
              Icons.copy_outlined,
              l10n.copyText,
              onCopy,
            ),
            if (onRemove case final remove?)
              action(
                ReaderScreen.removeHighlightButton,
                Icons.delete_outline,
                l10n.removeHighlight,
                remove,
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  for (final c in HighlightColor.values)
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: _Swatch(
                        color: c,
                        chosen: c == color,
                        label: colorName(context, c),
                        onTap: () => onColor(c),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const width = 260.0;
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.chosen,
    required this.label,
    required this.onTap,
  });

  final HighlightColor color;
  final bool chosen;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: label,
    child: Semantics(
      button: true,
      selected: chosen,
      label: label,
      child: InkResponse(
        key: ReaderScreen.highlightColor(color),
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.color,
            shape: BoxShape.circle,
            border: chosen
                ? Border.all(
                    color: Theme.of(context).colorScheme.onSurface,
                    width: 2,
                  )
                : null,
          ),
          child: chosen
              ? const Icon(Icons.check, size: 20, color: Colors.white)
              : null,
        ),
      ),
    ),
  );
}
