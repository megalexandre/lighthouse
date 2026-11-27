import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart';
import '../data/highlight.dart';
import 'reader_screen.dart';

/// What can be done with the text selected, or with a highlight tapped:
/// write a note, record a voice note (or play and delete the one it has),
/// copy, remove the highlight, and a colour for it (picking one is what
/// highlights a selection).
class HighlightMenu extends StatelessWidget {
  const HighlightMenu({
    super.key,
    required this.onColor,
    required this.onNote,
    required this.onCopy,
    required this.onRecord,
    this.color,
    this.note = '',
    this.onRemove,
    this.voiceLength,
    this.voicePlaying = false,
    this.onPlayVoice,
    this.onDeleteVoice,
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
  final VoidCallback onRecord;

  /// How long the highlight's voice note is; null when it has none.
  final Duration? voiceLength;
  final bool voicePlaying;
  final VoidCallback? onPlayVoice;
  final VoidCallback? onDeleteVoice;

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
            if (voiceLength case final length?)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      key: ReaderScreen.playVoiceButton,
                      tooltip: voicePlaying ? l10n.stopVoice : l10n.playVoice,
                      icon: Icon(
                        voicePlaying
                            ? Icons.stop_circle_outlined
                            : Icons.play_circle_outline,
                      ),
                      onPressed: onPlayVoice,
                    ),
                    Expanded(
                      child: Text(
                        l10n.voiceNote(clockText(length)),
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                    IconButton(
                      key: ReaderScreen.deleteVoiceButton,
                      tooltip: l10n.deleteVoice,
                      icon: const Icon(Icons.delete_outline),
                      onPressed: onDeleteVoice,
                    ),
                  ],
                ),
              )
            else
              action(
                ReaderScreen.recordVoiceButton,
                Icons.mic_none,
                l10n.recordVoice,
                onRecord,
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

/// [length] as m:ss (h:mm:ss past an hour).
String clockText(Duration length) {
  final s = length.inSeconds;
  String two(int n) => n.toString().padLeft(2, '0');
  return s >= 3600
      ? '${s ~/ 3600}:${two(s ~/ 60 % 60)}:${two(s % 60)}'
      : '${s ~/ 60}:${two(s % 60)}';
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
