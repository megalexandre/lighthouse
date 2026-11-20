import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../l10n/l10n.dart';
import '../application/reader_controller.dart';
import 'reader_screen.dart';

/// The bars over the page: back, title, contents, bookmark and display
/// settings above; the page slider below.
class ReaderChrome extends StatelessWidget {
  const ReaderChrome({
    super.key,
    required this.session,
    this.shown,
    required this.onBack,
    required this.onSeek,
    required this.onContents,
    required this.onBookmark,
    required this.onDisplay,
  });

  final ReaderSession session;

  /// The first and last pages shown, when two are side by side.
  final (int, int)? shown;
  final VoidCallback onBack;
  final ValueChanged<int> onSeek;
  final VoidCallback onContents;
  final VoidCallback onBookmark;
  final VoidCallback onDisplay;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _TopBar(
        session: session,
        onBack: onBack,
        onContents: onContents,
        onBookmark: onBookmark,
        onDisplay: onDisplay,
      ),
      const Spacer(),
      _BottomBar(session: session, shown: shown, onSeek: onSeek),
    ],
  );
}

/// Back, the book's title, contents, bookmark and display settings.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.session,
    required this.onBack,
    required this.onContents,
    required this.onBookmark,
    required this.onDisplay,
  });

  final ReaderSession session;
  final VoidCallback onBack;
  final VoidCallback onContents;
  final VoidCallback onBookmark;
  final VoidCallback onDisplay;

  @override
  Widget build(BuildContext context) {
    final ink = context.tokens.osdInk;
    return Material(
      color: context.tokens.osdSurface,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              key: ReaderScreen.backButton,
              color: ink,
              tooltip: context.l10n.back,
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack,
            ),
            Expanded(
              child: Text(
                session.item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(color: ink),
              ),
            ),
            IconButton(
              key: ReaderScreen.contentsButton,
              color: ink,
              tooltip: context.l10n.contentsAndBookmarks,
              icon: const Icon(Icons.toc),
              onPressed: onContents,
            ),
            IconButton(
              key: ReaderScreen.bookmarkButton,
              color: ink,
              tooltip: session.bookmarked
                  ? context.l10n.removeBookmark
                  : context.l10n.bookmarkPage,
              isSelected: session.bookmarked,
              icon: const Icon(Icons.bookmark_border),
              selectedIcon: const Icon(Icons.bookmark),
              onPressed: onBookmark,
            ),
            IconButton(
              key: ReaderScreen.displayButton,
              color: ink,
              tooltip: context.l10n.display,
              icon: const Icon(Icons.text_format),
              onPressed: onDisplay,
            ),
          ],
        ),
      ),
    );
  }
}

/// The page slider (a book of more than one page) and "Page n of m".
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.session,
    required this.shown,
    required this.onSeek,
  });

  final ReaderSession session;
  final (int, int)? shown;
  final ValueChanged<int> onSeek;

  @override
  Widget build(BuildContext context) {
    final count = session.pageCount;
    return Material(
      color: context.tokens.osdSurface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: count > 1
                    ? Slider(
                        key: ReaderScreen.slider,
                        max: (count - 1).toDouble(),
                        divisions: count - 1,
                        value: session.page.toDouble(),
                        label: '${session.page + 1}',
                        onChanged: (v) => onSeek(v.round()),
                      )
                    : const SizedBox.shrink(),
              ),
              Text(
                switch (shown) {
                  (final first, final last) when first != last =>
                    context.l10n.pagesOf(first + 1, last + 1, count),
                  _ => context.l10n.pageOf(session.page + 1, count),
                },
                key: ReaderScreen.pageText,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: context.tokens.osdInkMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
