import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../widgets/error_retry.dart';
import '../application/reader_controller.dart';
import 'page_curl/page_curl_view.dart';

/// Reads a book page by page, as Google Play Books does: pages turn like
/// paper under the finger (drag on the right half, or the left half to go
/// back; see page_curl/); a tap on the left / right edge or the arrow keys
/// turn them too; a tap in the middle shows or hides the bars; the slider
/// at the bottom jumps anywhere.
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

  /// Part of the width, at each side, where a tap turns the page.
  static const edge = 0.25;

  /// The page's paper, the "desk" around it, and the room left around
  /// the page for the bars.
  static const paper = Color(0xFFFFFFFF);
  static const desk = Color(0xFF303134);
  static const margin = EdgeInsets.fromLTRB(12, 52, 12, 60);

  final String itemId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _curl = GlobalKey<PageCurlViewState>();
  bool _chromeVisible = true;

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
        backgroundColor: ReaderScreen.desk,
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
          color: Colors.white,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
    ],
  );

  /// Sheet [index] at rest: the page on its paper.
  Widget _sheet(ReaderSession session, int index) => ColoredBox(
    color: ReaderScreen.paper,
    child: Center(child: session.document.buildPage(index)),
  );

  Widget _reading(BuildContext context, ReaderSession session) {
    return Focus(
      autofocus: true,
      onKeyEvent: (_, event) => _onKey(session, event),
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (details) {
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
                    aspectRatio: session.document.pageAspectRatio(session.page),
                    child: PageCurlView(
                      key: _curl,
                      pageCount: session.pageCount,
                      page: session.page,
                      paper: ReaderScreen.paper,
                      sheetBuilder: (index) => KeyedSubtree(
                        key: index == session.page ? ReaderScreen.pages : null,
                        child: _sheet(session, index),
                      ),
                      sheetImage: (index, size, ratio) =>
                          sheetImage(session, index, size, ratio),
                      onTurned: _controller.goTo,
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
                ),
              ),
            ),
          ],
        ),
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
  double pixelRatio,
) async {
  final area = Offset.zero & size;
  final page = await session.document.pageImage(
    index,
    Size(area.width * pixelRatio, area.height * pixelRatio),
  );
  final natural = Size(page.width.toDouble(), page.height.toDouble());
  final fitted = applyBoxFit(BoxFit.contain, natural, area.size);
  final target = Alignment.center.inscribe(fitted.destination, area);

  final recorder = ui.PictureRecorder();
  Canvas(recorder)
    ..scale(pixelRatio)
    ..drawColor(ReaderScreen.paper, BlendMode.src)
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

/// The bars over the page: back and title above; the page slider below.
class _Chrome extends StatelessWidget {
  const _Chrome({
    required this.session,
    required this.onBack,
    required this.onSeek,
  });

  final ReaderSession session;
  final VoidCallback onBack;
  final ValueChanged<int> onSeek;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const bar = Color(0xE6202124);
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
                  color: Colors.white,
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: onBack,
                ),
                Expanded(
                  child: Text(
                    session.item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
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
                    'Page ${session.page + 1} of $count',
                    key: ReaderScreen.pageText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
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
