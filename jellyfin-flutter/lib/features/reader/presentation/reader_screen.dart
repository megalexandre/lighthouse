import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_tokens.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/error_retry.dart';
import '../application/reader_controller.dart';
import '../application/reader_preferences.dart';
import '../data/book_document.dart';
import 'page_curl/page_curl_view.dart';

/// Reads a book page by page, as Google Play Books does: pages turn like
/// paper under the finger (drag on the right half, or the left half to go
/// back; see page_curl/); a tap on the left / right edge or the arrow keys
/// turn them too; a tap in the middle shows or hides the bars; the slider
/// at the bottom jumps anywhere. The top bar opens the contents and
/// bookmarks, bookmarks the page, and sets the theme (and an EPUB's type);
/// a tap on a link in an EPUB follows it, with a button to come back.
///
/// Keys: ← → PgUp PgDn turn pages, Space the next one, Home / End the
/// first / last, Esc or Backspace back.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.itemId});

  static const backButton = Key('reader.back');
  static const pages = Key('reader.pages');
  static const slider = Key('reader.slider');
  static const pageText = Key('reader.pageText');
  static const chrome = Key('reader.chrome');
  static const contentsButton = Key('reader.contents');
  static const bookmarkButton = Key('reader.bookmark');
  static const displayButton = Key('reader.display');
  static const linkBack = Key('reader.linkBack');
  static const contentsTab = Key('reader.contentsTab');
  static const bookmarksTab = Key('reader.bookmarksTab');
  static const fontSmaller = Key('reader.fontSmaller');
  static const fontBigger = Key('reader.fontBigger');
  static const fontSize = Key('reader.fontSize');
  static Key themeChoice(ReaderTheme theme) =>
      Key('reader.theme.${theme.name}');
  static Key typefaceChoice({required bool sans}) =>
      Key('reader.typeface.${sans ? 'sans' : 'serif'}');

  /// Part of the width, at each side, where a tap turns the page.
  static const edge = 0.25;

  /// The room left around the page for the bars. (The paper and the desk
  /// around it are the theme's: [ReaderTheme].)
  static const margin = EdgeInsets.fromLTRB(12, 52, 12, 60);

  final String itemId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _curl = GlobalKey<PageCurlViewState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  bool _chromeVisible = true;

  /// The keys go to the book. Asked for when it appears (autofocus alone
  /// loses to whatever held focus while the route was coming in) and
  /// again on any click or touch on the page.
  final _focus = FocusNode(debugLabel: 'reader');
  bool _focusAsked = false;

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  ReaderController get _controller =>
      ref.read(readerControllerProvider(widget.itemId).notifier);

  /// Saves the place, then leaves.
  Future<void> _close() async {
    await _controller.close();
    if (mounted && context.canPop()) context.pop();
  }

  void _next() => _curl.currentState?.turnNext();
  void _previous() => _curl.currentState?.turnPrevious();

  KeyEventResult _onKey(ReaderSession session, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowRight ||
        key == LogicalKeyboardKey.pageDown ||
        key == LogicalKeyboardKey.space) {
      _next();
    } else if (key == LogicalKeyboardKey.arrowLeft ||
        key == LogicalKeyboardKey.pageUp) {
      _previous();
    } else if (key == LogicalKeyboardKey.home) {
      _controller.goTo(0);
    } else if (key == LogicalKeyboardKey.end) {
      _controller.goTo(session.pageCount - 1);
    } else if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.backspace) {
      if (event is KeyDownEvent) unawaited(_close());
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  ReaderTheme get _theme =>
      ref.watch(readerPreferencesProvider).value?.theme ?? ReaderTheme.light;

  @override
  Widget build(BuildContext context) {
    final provider = readerControllerProvider(widget.itemId);
    final session = ref.watch(provider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_close());
      },
      child: Scaffold(
        key: _scaffold,
        backgroundColor: _theme.desk,
        drawer: switch (session) {
          AsyncData(value: final session) => _ContentsDrawer(
            session: session,
            onGoTo: (fraction) {
              _scaffold.currentState?.closeDrawer();
              _controller.goToFraction(fraction);
            },
            onRemoveBookmark: (f) => unawaited(_controller.removeBookmark(f)),
          ),
          _ => null,
        },
        // Horizontal drags turn pages; the drawer opens from its button.
        drawerEnableOpenDragGesture: false,
        // The keys go back to the book when the drawer closes.
        onDrawerChanged: (open) {
          if (!open) _focus.requestFocus();
        },
        body: switch (session) {
          AsyncData(value: final session) => _reading(context, session),
          AsyncError(:final error) => _message(
            ErrorRetry(error: error, onRetry: () => ref.invalidate(provider)),
          ),
          _ => _message(const CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _message(Widget child) => Stack(
    children: [
      Center(child: child),
      SafeArea(
        child: IconButton(
          key: ReaderScreen.backButton,
          color: context.tokens.osdInk,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
    ],
  );

  /// Sheet [index] at rest: the page on its paper.
  Widget _sheet(ReaderSession session, int index, PageColors colors) =>
      ColoredBox(
        color: colors.paper,
        child: Center(child: session.document.buildPage(index, colors)),
      );

  /// A tap on a link in the page follows it. True when there was one.
  bool _followLink(Offset global) {
    final box = _curl.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.hasSize || box.size.isEmpty) return false;
    final local = box.globalToLocal(global);
    if (!(Offset.zero & box.size).contains(local)) return false;
    return _controller.followLink(
      Offset(local.dx / box.size.width, local.dy / box.size.height),
    );
  }

  Future<void> _showDisplaySettings(ReaderSession session) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      // The page stays as it is, to see each choice on it.
      barrierColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 480),
      builder: (_) => _DisplaySheet(reflowable: session.document.reflowable),
    );
    _focus.requestFocus();
  }

  /// An EPUB's page: the shape of a book's, between 0.55 and 0.72 (wide
  /// enough for comfortable lines on a phone, not a wall of text on a
  /// desktop), as large as fits in [screen].
  static double _reflowAspect(Size screen) {
    final room = ReaderScreen.margin.deflateSize(screen);
    if (room.isEmpty) return 2 / 3;
    return room.aspectRatio.clamp(0.55, 0.72);
  }

  /// The sheet an EPUB is laid out for, in [screen].
  static Size _reflowSheet(Size screen) {
    final room = ReaderScreen.margin.deflateSize(screen);
    final aspect = _reflowAspect(screen);
    final width = room.width / room.height > aspect
        ? room.height * aspect
        : room.width;
    return Size(width, width / aspect);
  }

  /// The sheet size last asked for (an EPUB), so a rebuild asks only on a
  /// change.
  Size? _laidOutFor;

  Widget _reading(BuildContext context, ReaderSession session) {
    if (!_focusAsked) {
      _focusAsked = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focus.requestFocus();
      });
    }
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (_, event) => _onKey(session, event),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (session.document.reflowable) {
            final sheet = _reflowSheet(constraints.biggest);
            // Pages are cut for the sheet once its size is known (after
            // this frame: state cannot change while building).
            if (sheet != _laidOutFor && !sheet.isEmpty) {
              _laidOutFor = sheet;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _controller.layout(sheet);
              });
            }
          }
          final colors = _theme.pageColors;
          return Stack(
            fit: StackFit.expand,
            children: [
              // Sees every touch without taking part in deciding what it is
              // (a tap, a page turn).
              Listener(
                onPointerDown: (_) => _focus.requestFocus(),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    if (session.document.reflowable &&
                        _followLink(details.globalPosition)) {
                      return;
                    }
                    final x = details.localPosition.dx / constraints.maxWidth;
                    if (x < ReaderScreen.edge) {
                      _previous();
                    } else if (x > 1 - ReaderScreen.edge) {
                      _next();
                    } else {
                      setState(() => _chromeVisible = !_chromeVisible);
                    }
                  },
                  // The sheet that turns is the page itself: its shape, as
                  // large as fits, on the desk.
                  child: Padding(
                    padding: ReaderScreen.margin,
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: session.document.reflowable
                            ? _reflowAspect(constraints.biggest)
                            : session.document.pageAspectRatio(session.page),
                        child: session.pageCount == 0
                            ? const SizedBox.shrink()
                            : PageCurlView(
                                key: _curl,
                                pageCount: session.pageCount,
                                page: session.page,
                                paper: colors.paper,
                                // New colours: new pictures too.
                                layoutVersion: Object.hash(
                                  session.document.layoutVersion,
                                  colors,
                                ),
                                sheetBuilder: (index) => KeyedSubtree(
                                  key: index == session.page
                                      ? ReaderScreen.pages
                                      : null,
                                  child: _sheet(session, index, colors),
                                ),
                                sheetImage: (index, size, ratio) => sheetImage(
                                  session,
                                  index,
                                  size,
                                  ratio,
                                  colors,
                                ),
                                onTurned: _controller.goTo,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedOpacity(
                key: ReaderScreen.chrome,
                opacity: _chromeVisible ? 1 : 0,
                duration: const Duration(milliseconds: 150),
                child: IgnorePointer(
                  ignoring: !_chromeVisible,
                  child: _Chrome(
                    session: session,
                    onBack: () => unawaited(_close()),
                    onSeek: _controller.goTo,
                    onContents: () => _scaffold.currentState?.openDrawer(),
                    onBookmark: () => unawaited(_controller.toggleBookmark()),
                    onDisplay: () => unawaited(_showDisplaySettings(session)),
                  ),
                ),
              ),
              if (session.linkedFrom case final from?)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: ReaderScreen.margin.bottom + 8,
                  child: Center(
                    child: ActionChip(
                      key: ReaderScreen.linkBack,
                      avatar: const Icon(Icons.undo, size: 18),
                      label: Text(
                        context.l10n.backToPage(
                          session.document.pageAt(from) + 1,
                        ),
                      ),
                      onPressed: _controller.returnFromLink,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Sheet [index] as one image, laid out exactly like [_ReaderScreenState]
/// lays it out at rest (paper, page fitted in the middle), so the switch
/// between the live page and the bending picture does not show.
Future<ui.Image> sheetImage(
  ReaderSession session,
  int index,
  Size size,
  double pixelRatio, [
  PageColors colors = PageColors.plain,
]) async {
  final area = Offset.zero & size;
  final page = await session.document.pageImage(
    index,
    Size(area.width * pixelRatio, area.height * pixelRatio),
    colors,
  );
  final natural = Size(page.width.toDouble(), page.height.toDouble());
  final fitted = applyBoxFit(BoxFit.contain, natural, area.size);
  final target = Alignment.center.inscribe(fitted.destination, area);

  final recorder = ui.PictureRecorder();
  Canvas(recorder)
    ..scale(pixelRatio)
    ..drawColor(colors.paper, BlendMode.src)
    ..drawImageRect(
      page,
      Offset.zero & natural,
      target,
      Paint()..filterQuality = FilterQuality.medium,
    );
  page.dispose();
  final picture = recorder.endRecording();
  try {
    return await picture.toImage(
      (size.width * pixelRatio).round(),
      (size.height * pixelRatio).round(),
    );
  } finally {
    picture.dispose();
  }
}

/// The bars over the page: back, title, contents, bookmark and display
/// settings above; the page slider below.
class _Chrome extends StatelessWidget {
  const _Chrome({
    required this.session,
    required this.onBack,
    required this.onSeek,
    required this.onContents,
    required this.onBookmark,
    required this.onDisplay,
  });

  final ReaderSession session;
  final VoidCallback onBack;
  final ValueChanged<int> onSeek;
  final VoidCallback onContents;
  final VoidCallback onBookmark;
  final VoidCallback onDisplay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bar = context.tokens.osdSurface;
    final count = session.pageCount;
    return Column(
      children: [
        Material(
          color: bar,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                IconButton(
                  key: ReaderScreen.backButton,
                  color: context.tokens.osdInk,
                  tooltip: context.l10n.back,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                ),
                Expanded(
                  child: Text(
                    session.item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: context.tokens.osdInk,
                    ),
                  ),
                ),
                IconButton(
                  key: ReaderScreen.contentsButton,
                  color: context.tokens.osdInk,
                  tooltip: context.l10n.contentsAndBookmarks,
                  icon: const Icon(Icons.toc),
                  onPressed: onContents,
                ),
                IconButton(
                  key: ReaderScreen.bookmarkButton,
                  color: context.tokens.osdInk,
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
                  color: context.tokens.osdInk,
                  tooltip: context.l10n.display,
                  icon: const Icon(Icons.text_format),
                  onPressed: onDisplay,
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Material(
          color: bar,
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
                    context.l10n.pageOf(session.page + 1, count),
                    key: ReaderScreen.pageText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: context.tokens.osdInkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The book's contents and the user's bookmarks, side by side in tabs.
class _ContentsDrawer extends StatefulWidget {
  const _ContentsDrawer({
    required this.session,
    required this.onGoTo,
    required this.onRemoveBookmark,
  });

  final ReaderSession session;

  /// Go to a fraction of the book.
  final ValueChanged<double> onGoTo;
  final ValueChanged<double> onRemoveBookmark;

  @override
  State<_ContentsDrawer> createState() => _ContentsDrawerState();
}

class _ContentsDrawerState extends State<_ContentsDrawer> {
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

/// The theme, for any book; the type size and face, for an EPUB.
class _DisplaySheet extends ConsumerWidget {
  const _DisplaySheet({required this.reflowable});

  final bool reflowable;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefs =
        ref.watch(readerPreferencesProvider).value ?? const ReaderPreferences();
    // From the preferences at the time of the tap, not of this build: two
    // quick taps on "larger" are two steps.
    void update(ReaderPreferences Function(ReaderPreferences) change) {
      final now =
          ref.read(readerPreferencesProvider).value ??
          const ReaderPreferences();
      unawaited(ref.read(readerPreferencesProvider.notifier).set(change(now)));
    }

    final sizes = ReaderPreferences.fontSizes;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<ReaderTheme>(
            showSelectedIcon: false,
            segments: [
              for (final theme in ReaderTheme.values)
                ButtonSegment(
                  value: theme,
                  label: Text(
                    theme.label(context.l10n),
                    key: ReaderScreen.themeChoice(theme),
                  ),
                ),
            ],
            selected: {prefs.theme},
            onSelectionChanged: (s) =>
                update((p) => p.copyWith(theme: s.single)),
          ),
          if (reflowable) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton.outlined(
                  key: ReaderScreen.fontSmaller,
                  tooltip: context.l10n.smallerText,
                  icon: const Icon(Icons.text_decrease),
                  onPressed: prefs.fontSize > sizes.first
                      ? () => update((p) => p.resized(-1))
                      : null,
                ),
                Expanded(
                  child: Text(
                    context.l10n.fontSizePx(prefs.fontSize.round()),
                    key: ReaderScreen.fontSize,
                    textAlign: TextAlign.center,
                  ),
                ),
                IconButton.outlined(
                  key: ReaderScreen.fontBigger,
                  tooltip: context.l10n.largerText,
                  icon: const Icon(Icons.text_increase),
                  onPressed: prefs.fontSize < sizes.last
                      ? () => update((p) => p.resized(1))
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(
                  value: false,
                  label: Text(
                    context.l10n.serif,
                    key: ReaderScreen.typefaceChoice(sans: false),
                    style: const TextStyle(fontFamily: 'serif'),
                  ),
                ),
                ButtonSegment(
                  value: true,
                  label: Text(
                    context.l10n.sans,
                    key: ReaderScreen.typefaceChoice(sans: true),
                    style: const TextStyle(fontFamily: 'sans-serif'),
                  ),
                ),
              ],
              selected: {prefs.sansSerif},
              onSelectionChanged: (s) =>
                  update((p) => p.copyWith(sansSerif: s.single)),
            ),
          ],
        ],
      ),
    );
  }
}
