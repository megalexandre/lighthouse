import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../l10n/l10n.dart';
import '../application/reader_controller.dart';
import '../data/book_document.dart';
import 'reader_screen.dart';

/// The book's contents and the user's bookmarks, side by side in tabs.
class ContentsDrawer extends StatefulWidget {
  const ContentsDrawer({
    super.key,
    required this.session,
    required this.onGoTo,
    required this.onRemoveBookmark,
  });

  final ReaderSession session;

  /// Go to a fraction of the book.
  final ValueChanged<double> onGoTo;
  final ValueChanged<double> onRemoveBookmark;

  @override
  State<ContentsDrawer> createState() => _ContentsDrawerState();
}

class _ContentsDrawerState extends State<ContentsDrawer> {
  /// Read once per book.
  static final _contents = Expando<Future<List<TocEntry>>>();

  Future<List<TocEntry>> get _toc =>
      _contents[widget.session.document] ??= widget.session.document.contents();

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    return Drawer(
      width: (MediaQuery.sizeOf(context).width * 0.85).clamp(0, 360),
      child: SafeArea(
        child: DefaultTabController(
          length: 2,
          child: Column(
            children: [
              TabBar(
                tabs: [
                  Tab(
                    key: ReaderScreen.contentsTab,
                    text: context.l10n.contents,
                  ),
                  Tab(
                    key: ReaderScreen.bookmarksTab,
                    text: context.l10n.bookmarks,
                  ),
                ],
              ),
              Expanded(
                child: FutureBuilder(
                  future: _toc,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final toc = snapshot.data ?? const <TocEntry>[];
                    return TabBarView(
                      children: [
                        _contentsList(context, session, toc),
                        _bookmarksList(context, session, toc),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The entry [fraction] falls under: the last one at or before it.
  static TocEntry? _entryAt(List<TocEntry> toc, double fraction) =>
      toc.lastWhere((e) => e.fraction <= fraction + 1e-9, orElse: () => _none);
  static const _none = TocEntry('', -1);

  Widget _contentsList(
    BuildContext context,
    ReaderSession session,
    List<TocEntry> toc,
  ) {
    if (toc.isEmpty) {
      return _Empty(context.l10n.noContents);
    }
    final document = session.document;
    final current = _entryAt(toc, document.fractionOf(session.page));
    return ListView(
      children: [
        for (final entry in toc)
          ListTile(
            dense: entry.depth > 0,
            selected: identical(entry, current),
            contentPadding: EdgeInsets.only(
              left: 16.0 + 16 * entry.depth.clamp(0, 4),
              right: 16,
            ),
            title: Text(
              entry.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: document.pageCount == 0
                ? null
                : Text('${document.pageAt(entry.fraction) + 1}'),
            onTap: () => widget.onGoTo(entry.fraction),
          ),
      ],
    );
  }

  Widget _bookmarksList(
    BuildContext context,
    ReaderSession session,
    List<TocEntry> toc,
  ) {
    if (session.bookmarks.isEmpty) {
      return _Empty(context.l10n.noBookmarks);
    }
    final document = session.document;
    return ListView(
      children: [
        for (final fraction in session.bookmarks)
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: Text(context.l10n.page(document.pageAt(fraction) + 1)),
            subtitle: switch (_entryAt(toc, fraction)) {
              final TocEntry e when e.fraction >= 0 => Text(
                e.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              _ => null,
            },
            trailing: IconButton(
              tooltip: context.l10n.removeBookmark,
              icon: const Icon(Icons.delete_outline),
              onPressed: () => widget.onRemoveBookmark(fraction),
            ),
            onTap: () => widget.onGoTo(fraction),
          ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Text(text, textAlign: TextAlign.center),
    ),
  );
}
