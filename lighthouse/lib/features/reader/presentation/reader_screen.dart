import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/log.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/touch.dart';
import '../../../core/window.dart';
import '../../../core/window_size.dart';
import '../../../l10n/l10n.dart';
import '../../../widgets/error_retry.dart';
import '../../../widgets/loading_ring.dart';
import '../application/reader_controller.dart';
import '../application/reader_preferences.dart';
import '../data/book_document.dart';
import '../data/highlight.dart';
import '../data/voice_note.dart';
import 'contents_drawer.dart';
import 'display_sheet.dart';
import 'highlight_menu.dart';
import 'page_curl/page_curl_view.dart';
import 'reader_chrome.dart';
import 'spreads.dart';

/// Reads a book page by page, or two pages side by side as an open book
/// when the window is wide enough or the user asks (see [Spreads]), as
/// Google Play Books does: pages turn like
/// paper under the finger (drag on the right half, or the left half to go
/// back; see page_curl/); a tap on the left / right edge or the arrow keys
/// turn them too; a tap in the middle shows or hides the bars; the slider
/// at the bottom jumps anywhere. The top bar opens the contents and
/// bookmarks, bookmarks the page, and sets the theme (and an EPUB's type);
/// a tap on a link in an EPUB follows it, with a button to come back.
///
/// An EPUB's text can be selected: dragged over with a mouse, or held
/// (then dragged) on touch. A menu over it highlights it in a colour, adds
/// a note or a voice note, or copies it; a tap on a highlight brings the
/// same menu back (where its voice note plays, or is deleted).
/// Highlights are listed under Notes in the contents.
///
/// On touch (a phone, a tablet) the page is laid out for the whole screen
/// and the bars come over it. The book opens without them; they are hidden
/// and shown together with the system's bars (full screen). With a mouse,
/// full screen (F11, F or its button; Esc leaves it) is the same page over
/// the whole screen, and the bars come and go with a click; the mouse wheel
/// turns pages (down: the next one), and so does a swipe of two fingers on a
/// touchpad, one page each (left or up: the next one). On a phone it is always one page at a
/// time ([showsTwoPages]).
///
/// Keys: ← → PgUp PgDn turn pages, Space the next one, Home / End the
/// first / last, F11 or F full screen, Esc out of the selection, out of
/// full screen or back, Backspace back, Ctrl+C copies the selection.
class ReaderScreen extends ConsumerStatefulWidget {
  const ReaderScreen({super.key, required this.itemId});

  static const backButton = Key('reader.back');
  static const pages = Key('reader.pages');

  /// The page on the left, with two side by side.
  static const leftPage = Key('reader.leftPage');
  static const slider = Key('reader.slider');
  static const pageText = Key('reader.pageText');
  static const chrome = Key('reader.chrome');
  static const contentsButton = Key('reader.contents');
  static const bookmarkButton = Key('reader.bookmark');
  static const displayButton = Key('reader.display');
  static const fullScreenButton = Key('reader.fullScreen');
  static const linkBack = Key('reader.linkBack');
  static const contentsTab = Key('reader.contentsTab');
  static const bookmarksTab = Key('reader.bookmarksTab');
  static const fontSmaller = Key('reader.fontSmaller');
  static const fontBigger = Key('reader.fontBigger');
  static const fontSize = Key('reader.fontSize');
  static Key themeChoice(ReaderTheme theme) =>
      Key('reader.theme.${theme.name}');
  static const fontMenu = Key('reader.font');
  static const lineSpacingSmaller = Key('reader.lineSpacingSmaller');
  static const lineSpacingBigger = Key('reader.lineSpacingBigger');
  static const lineSpacing = Key('reader.lineSpacing');
  static const letterSpacingSmaller = Key('reader.letterSpacingSmaller');
  static const letterSpacingBigger = Key('reader.letterSpacingBigger');
  static const letterSpacing = Key('reader.letterSpacing');
  static Key justifyChoice({required bool justify}) =>
      Key('reader.justify.$justify');
  static Key layoutChoice(PageLayout layout) =>
      Key('reader.layout.${layout.name}');
  static const notesTab = Key('reader.notesTab');
  static const highlightMenu = Key('reader.highlightMenu');
  static Key highlightColor(HighlightColor color) =>
      Key('reader.highlight.${color.name}');
  static const noteButton = Key('reader.note');
  static const copyButton = Key('reader.copy');
  static const removeHighlightButton = Key('reader.removeHighlight');
  static const noteField = Key('reader.noteField');
  static const recordVoiceButton = Key('reader.recordVoice');
  static const playVoiceButton = Key('reader.playVoice');
  static const deleteVoiceButton = Key('reader.deleteVoice');
  static const saveRecordingButton = Key('reader.saveRecording');

  /// Part of the width, at each side, where a tap turns the page.
  static const edge = 0.25;

  /// The room left around the page for the bars, with a mouse. (The paper
  /// and the desk around it are the theme's: [ReaderTheme].)
  static const margin = EdgeInsets.fromLTRB(12, 52, 12, 60);

  /// The room around two pages on touch, inside the system's bars: the
  /// reader's bars come over them instead. One page has no room around it:
  /// its sheet is the whole screen.
  static const touchMargin = EdgeInsets.all(8);

  /// The least between an EPUB's text and the system's bars or notch, when
  /// the sheet is the whole screen.
  static const _clearance = 8.0;

  /// The widest an EPUB's lines get when the sheet is the whole screen (a
  /// phone on its side, a tablet): longer ones are hard to follow.
  static const maxLineWidth = 640.0;

  final String itemId;

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  final _curl = GlobalKey<PageCurlViewState>();
  final _scaffold = GlobalKey<ScaffoldState>();
  bool _chromeVisible = true;

  /// The window, read once: dispose gives the system's bars back, and a
  /// provider cannot be read there.
  late final AppWindow _window = ref.read(appWindowProvider);

  /// Whether this screen made the window full screen (on touch: hid the
  /// system's bars).
  bool _fullScreen = false;

  /// Shows or hides the bars; on touch the system's too (full screen).
  void _showChrome(bool visible) {
    setState(() => _chromeVisible = visible);
    if (isTouch(context)) {
      _fullScreen = !visible;
      _window.isFullScreen = _fullScreen;
    }
  }

  /// In or out of full screen. On touch it goes with the bars; with a mouse
  /// the bars go as it comes in, and a click brings them over the page.
  void _toggleFullScreen() {
    if (isTouch(context)) return _showChrome(_fullScreen);
    final value = !_fullScreen;
    setState(() {
      _fullScreen = value;
      _chromeVisible = !value;
    });
    _window.isFullScreen = value;
  }

  /// The system's bars and notch, as large as they have been in this
  /// orientation: hiding the bars must not move the page, which for an EPUB
  /// would lay the whole book out again.
  EdgeInsets _insets = EdgeInsets.zero;
  Orientation? _insetsFor;

  EdgeInsets _systemInsets(BuildContext context) {
    final now = MediaQuery.viewPaddingOf(context);
    final orientation = MediaQuery.orientationOf(context);
    if (orientation != _insetsFor) {
      _insetsFor = orientation;
      _insets = now;
    } else {
      _insets = EdgeInsets.fromLTRB(
        math.max(_insets.left, now.left),
        math.max(_insets.top, now.top),
        math.max(_insets.right, now.right),
        math.max(_insets.bottom, now.bottom),
      );
    }
    return _insets;
  }

  /// The keys go to the book. Asked for when it appears (autofocus alone
  /// loses to whatever held focus while the route was coming in) and
  /// again on any click or touch on the page.
  final _focus = FocusNode(debugLabel: 'reader');
  bool _focusAsked = false;

  /// Voice notes play here; read once, as [_window] (dispose stops it).
  late final NotePlayer _voices = ref.read(notePlayerProvider);

  @override
  void initState() {
    super.initState();
    _window.staysOn = true;
    _voices; // Read now: dispose cannot.
  }

  @override
  void dispose() {
    // A voice note does not go on playing past the book.
    unawaited(_voices.stop());
    _window.staysOn = false;
    if (_fullScreen) _window.isFullScreen = false;
    _focus.dispose();
    _wheelRest?.cancel();
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

  /// Wheel travel not yet turned into a page, in logical pixels.
  double _wheel = 0;

  /// Set right after the wheel turns a page: a touchpad sends many small
  /// scrolls, and one flick of a wheel several notches, for a single turn.
  Timer? _wheelRest;

  /// How far the wheel goes for one page: about one notch.
  static const _wheelStep = 40.0;
  static const _wheelPause = Duration(milliseconds: 250);

  /// A touchpad swipe already turned its page.
  bool _swipeTurned = false;

  /// How far two fingers go on a touchpad to turn a page.
  static const _swipeStep = 60.0;

  /// Two fingers on a touchpad turn one page per swipe, as they would move
  /// the page: left or up the next, right or down the previous. (Its
  /// scrolls are not wheel turns: Flutter hands them over as a pan.)
  void _onSwipe(PointerPanZoomUpdateEvent event) {
    if (_swipeTurned) return;
    final pan = event.pan;
    final along = pan.dx.abs() > pan.dy.abs() ? pan.dx : pan.dy;
    if (along.abs() < _swipeStep) return;
    _swipeTurned = true;
    along < 0 ? _next() : _previous();
  }

  /// The wheel turns pages: down (or right) the next, up the previous.
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    GestureBinding.instance.pointerSignalResolver.register(event, (event) {
      if (_wheelRest?.isActive ?? false) return;
      final delta = (event as PointerScrollEvent).scrollDelta;
      _wheel += delta.dy != 0 ? delta.dy : delta.dx;
      if (_wheel.abs() < _wheelStep) return;
      final forward = _wheel > 0;
      _wheel = 0;
      _wheelRest = Timer(_wheelPause, () {});
      forward ? _next() : _previous();
    });
  }

  KeyEventResult _onKey(ReaderSession session, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    if (_menuRange != null) {
      if (key == LogicalKeyboardKey.escape) {
        setState(_clearSelection);
        return KeyEventResult.handled;
      }
      if (key == LogicalKeyboardKey.keyC &&
          HardwareKeyboard.instance.isControlPressed) {
        if (event is KeyDownEvent) unawaited(_copy());
        return KeyEventResult.handled;
      }
    }
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
    } else if (key == LogicalKeyboardKey.f11 ||
        key == LogicalKeyboardKey.keyF) {
      if (event is KeyDownEvent) _toggleFullScreen();
    } else if (key == LogicalKeyboardKey.escape &&
        _fullScreen &&
        !isTouch(context)) {
      if (event is KeyDownEvent) _toggleFullScreen();
    } else if (key == LogicalKeyboardKey.escape ||
        key == LogicalKeyboardKey.backspace) {
      if (event is KeyDownEvent) unawaited(_close());
    } else {
      return KeyEventResult.ignored;
    }
    return KeyEventResult.handled;
  }

  ReaderPreferences get _prefs =>
      ref.watch(readerPreferencesProvider).value ?? const ReaderPreferences();

  ReaderTheme get _theme => _prefs.theme;

  @override
  Widget build(BuildContext context) {
    final provider = readerControllerProvider(widget.itemId);
    final session = ref.watch(provider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        // The system's Back (Android) closes the contents first: this scope
        // keeps the route, so the drawer's own Back never runs.
        final scaffold = _scaffold.currentState;
        if (scaffold != null && scaffold.isDrawerOpen) {
          scaffold.closeDrawer();
        } else {
          unawaited(_close());
        }
      },
      child: Scaffold(
        key: _scaffold,
        backgroundColor: _theme.desk,
        drawer: switch (session) {
          AsyncData(value: final session) => ContentsDrawer(
            session: session,
            onGoTo: (fraction) {
              _scaffold.currentState?.closeDrawer();
              _controller.goToFraction(fraction);
            },
            onRemoveBookmark: (f) => unawaited(_controller.removeBookmark(f)),
            onRemoveHighlight: (h) {
              if (_isPlaying(h)) unawaited(_voices.stop());
              unawaited(_controller.removeHighlight(h));
            },
            voicePlaying: _voices.playing,
            onPlayVoice: (h) => unawaited(_playVoice(h)),
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
          _ => _message(const LoadingRing(size: 48, onMedia: true)),
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
          onPressed: context.pop,
        ),
      ),
    ],
  );

  /// Page [index] at rest: the page on its paper; blank paper for none
  /// (the back of the book, facing its last page).
  Widget _sheet(ReaderSession session, int? index, PageColors colors) =>
      ColoredBox(
        color: colors.paper,
        child: index == null
            ? const SizedBox.expand()
            : Center(
                child: session.document.buildPage(
                  index,
                  colors,
                  marks: _marks(session, index),
                ),
              ),
      );

  final _left = GlobalKey();
  final _right = GlobalKey();
  final _stack = GlobalKey();

  /// The spread shown, as last built.
  Spreads? _spreads;
  int _spread = 0;
  ReaderSession? _shown;

  /// The page shown at rest that holds [page], if it is one.
  RenderBox? _pageBox(int page) {
    final spreads = _spreads;
    if (spreads == null) return null;
    final key = spreads.left(_spread) == page
        ? _left
        : spreads.right(_spread) == page
        ? _right
        : null;
    final box = key?.currentContext?.findRenderObject();
    return box is RenderBox && box.hasSize && !box.size.isEmpty ? box : null;
  }

  /// The page under [global], and where on it in its unit square. With
  /// [page]: that page, wherever the point is.
  (int, Offset)? _pagePoint(Offset global, {int? page}) {
    final spreads = _spreads;
    if (spreads == null) return null;
    for (final index in [spreads.left(_spread), spreads.right(_spread)]) {
      if (index == null || (page != null && index != page)) continue;
      final box = _pageBox(index);
      if (box == null) continue;
      final local = box.globalToLocal(global);
      if (page == null && !(Offset.zero & box.size).contains(local)) continue;
      return (
        index,
        Offset(local.dx / box.size.width, local.dy / box.size.height),
      );
    }
    return null;
  }

  /// A tap on a link in a page follows it. True when there was one.
  bool _followLink(Offset global) {
    final (page, at) = _pagePoint(global) ?? (null, Offset.zero);
    return page != null && _controller.followLink(at, page: page);
  }

  // --- Selecting and highlighting -------------------------------------------

  /// The text selected, in book characters, on page [_selectionPage];
  /// [_anchor] is where it began (a word on touch), [_selecting] while the
  /// pointer is still down.
  TextRange? _selection;
  TextRange? _anchor;
  int? _selectionPage;
  bool _selecting = false;

  /// The highlight tapped, whose menu is open (on [_selectionPage]).
  Highlight? _openHighlight;

  /// A pointer came down while the menu was open: it only closes it.
  bool _dismissing = false;

  void _clearSelection() {
    _selection = _anchor = _selectionPage = _openHighlight = null;
    _selecting = false;
  }

  /// What the menu is for, once the pointer is up.
  TextRange? get _menuRange =>
      _openHighlight?.range ?? (_selecting ? null : _selection);

  BookDocument? get _document => _shown?.document;

  bool _onText(Offset global) {
    final document = _document;
    if (document == null || !document.selectable) return false;
    final (page, at) = _pagePoint(global) ?? (null, Offset.zero);
    return page != null && document.offsetAt(page, at) != null;
  }

  /// Starts a selection at [global]: the word there ([word], touch), or
  /// the place between two letters (a mouse).
  void _startSelection(Offset global, {required bool word}) {
    final document = _document;
    final (page, at) = _pagePoint(global) ?? (null, Offset.zero);
    if (document == null || page == null) return;
    final TextRange? anchor;
    if (word) {
      anchor = document.wordAt(page, at);
    } else {
      final offset = document.offsetAt(page, at);
      anchor = offset == null ? null : TextRange.collapsed(offset);
    }
    if (anchor == null) return;
    setState(() {
      _clearSelection();
      _selectionPage = page;
      _anchor = _selection = anchor;
      _selecting = true;
    });
  }

  /// Takes the selection from where it began to [global] (on its page).
  void _extendSelection(Offset global) {
    final document = _document;
    final page = _selectionPage;
    final anchor = _anchor;
    if (document == null || page == null || anchor == null) return;
    final (_, at) = _pagePoint(global, page: page) ?? (null, Offset.zero);
    final offset = document.offsetAt(page, at, near: true);
    if (offset == null) return;
    final range = offset < anchor.start
        ? TextRange(start: offset, end: anchor.end)
        : TextRange(start: anchor.start, end: math.max(offset, anchor.end));
    if (range != _selection) setState(() => _selection = range);
  }

  bool _selectsOnDrag(PointerDownEvent event) =>
      event.kind == PointerDeviceKind.mouse && _onText(event.position);

  /// A mouse dragged over text selects it, from where it went down.
  void _setUpSelectDrag(FilteredPan drag) {
    drag
      ..allows = _selectsOnDrag
      // A mouse only: a touchpad's two fingers scroll (see [_onSwipe]).
      ..supportedDevices = const {PointerDeviceKind.mouse}
      ..dragStartBehavior = DragStartBehavior.down
      ..onStart = (d) {
        _startSelection(d.globalPosition, word: false);
      }
      ..onUpdate = (d) {
        _extendSelection(d.globalPosition);
      }
      ..onEnd = (_) {
        _endSelection();
      }
      ..onCancel = _endSelection;
  }

  /// A finger held on a word selects it; moved, it takes in more.
  void _setUpSelectPress(LongPressGestureRecognizer press) {
    press
      ..onLongPressStart = (d) {
        _startSelection(d.globalPosition, word: true);
      }
      ..onLongPressMoveUpdate = (d) {
        _extendSelection(d.globalPosition);
      }
      ..onLongPressEnd = (_) {
        _endSelection();
      };
  }

  void _endSelection() {
    if (!_selecting) return;
    setState(() {
      _selecting = false;
      if (_selection?.isCollapsed ?? true) _clearSelection();
    });
  }

  /// The highlight drawn under [global], the last one made on top.
  (int, Highlight)? _highlightAt(Offset global) {
    final session = _shown;
    final (page, at) = _pagePoint(global) ?? (null, Offset.zero);
    if (session == null || page == null || !session.document.selectable) {
      return null;
    }
    for (final h in session.highlights.reversed) {
      final rects = session.document.rectsOf(page, h.range);
      if (rects.any((r) => r.inflate(0.002).contains(at))) return (page, h);
    }
    return null;
  }

  /// What page [page] draws under its text: the highlights, and the
  /// selection (or the highlight whose menu is open).
  List<PageMark> _marks(ReaderSession session, int page) {
    final selected = _openHighlight?.range ?? _selection;
    return [
      ..._highlightMarks(session),
      if (selected != null && !selected.isCollapsed && _selectionPage == page)
        PageMark(
          selected.start,
          selected.end,
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
    ];
  }

  static List<PageMark> _highlightMarks(ReaderSession session) => [
    for (final h in session.highlights) PageMark(h.start, h.end, h.color.fill),
  ];

  Future<void> _color(HighlightColor color) async {
    final open = _openHighlight;
    final selection = _selection;
    setState(_clearSelection);
    _focus.requestFocus();
    if (open != null) {
      await _controller.updateHighlight(open, color: color);
    } else if (selection != null) {
      await _controller.highlight(selection, color);
    }
  }

  /// Writes the note of the highlight open, or of the selection (which
  /// then becomes a yellow highlight, once the note is saved).
  Future<void> _note() async {
    final open = _openHighlight;
    final selection = _selection;
    setState(_clearSelection);
    final note = await showDialog<String>(
      context: context,
      builder: (_) => _NoteDialog(initial: open?.note ?? ''),
    );
    _focus.requestFocus();
    if (note == null) return;
    var target = open;
    if (target == null && selection != null) {
      target = await _controller.highlight(selection, HighlightColor.yellow);
    }
    if (target != null) {
      await _controller.updateHighlight(target, note: note);
    }
  }

  Future<void> _copy() async {
    final range = _menuRange;
    final document = _document;
    setState(_clearSelection);
    _focus.requestFocus();
    if (range == null || document == null) return;
    await Clipboard.setData(ClipboardData(text: document.textOf(range)));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(context.l10n.textCopied)));
  }

  Future<void> _remove() async {
    final open = _openHighlight;
    setState(_clearSelection);
    _focus.requestFocus();
    if (open == null) return;
    if (_isPlaying(open)) await _voices.stop();
    await _controller.removeHighlight(open);
  }

  // --- Voice notes ------------------------------------------------------------

  /// The longest voice note: past it, the recording ends and is kept.
  static const maxVoiceNote = Duration(minutes: 10);

  bool _isPlaying(Highlight h) =>
      h.hasVoice && (_voices.playing.value?.endsWith('/${h.voice}') ?? false);

  /// Plays [h]'s voice note, or stops it when it is the one playing.
  Future<void> _playVoice(Highlight h) async {
    if (_isPlaying(h)) return _voices.stop();
    final dir = await ref.read(voiceNotesDirectoryProvider.future);
    await _voices.play(File('${dir.path}/${h.voice}'));
  }

  /// Records a voice note for the highlight open, or for the selection
  /// (which then becomes a yellow highlight, once the note is saved). The
  /// menu goes; a dialog shows the time until Save or Cancel.
  Future<void> _recordVoice() async {
    final open = _openHighlight;
    final selection = _selection;
    setState(_clearSelection);
    final recorder = ref.read(noteRecorderProvider);
    final String file;
    try {
      await _voices.stop();
      final dir = await ref.read(voiceNotesDirectoryProvider.future);
      file = await recorder.start(dir);
    } on Object catch (e) {
      log.warning('reader', 'no voice note', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.recordingFailed)));
      _focus.requestFocus();
      return;
    }
    if (!mounted) return unawaited(recorder.cancel());
    final save = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _RecordingDialog(limit: maxVoiceNote),
    );
    _focus.requestFocus();
    if (save != true) return recorder.cancel();
    final length = await recorder.stop();
    var target = open;
    if (target == null && selection != null) {
      target = await _controller.highlight(selection, HighlightColor.yellow);
    }
    if (target != null) {
      await _controller.attachVoice(target, file, length);
    }
  }

  /// Deletes the voice note of the highlight open; its menu stays.
  Future<void> _deleteVoice() async {
    final open = _openHighlight;
    if (open == null) return;
    if (_isPlaying(open)) await _voices.stop();
    setState(() => _openHighlight = open.copyWith(voice: ''));
    await _controller.removeVoice(open);
  }

  /// Where [range] is on page [page], in the stack's coordinates.
  Rect? _rectOf(BookDocument document, int page, TextRange range) {
    final box = _pageBox(page);
    final stack = _stack.currentContext?.findRenderObject();
    if (box == null || stack is! RenderBox) return null;
    final rects = document.rectsOf(page, range);
    if (rects.isEmpty) return null;
    final unit = rects.reduce((a, b) => a.expandToInclude(b));
    Offset place(Offset p) => stack.globalToLocal(
      box.localToGlobal(Offset(p.dx * box.size.width, p.dy * box.size.height)),
    );
    return Rect.fromPoints(place(unit.topLeft), place(unit.bottomRight));
  }

  /// The menu, over (or under) the text it is for.
  Widget? _menu(ReaderSession session) {
    final range = _menuRange;
    final page = _selectionPage;
    if (range == null || page == null) return null;
    final anchor = _rectOf(session.document, page, range);
    if (anchor == null) return null;
    final open = _openHighlight;
    return CustomSingleChildLayout(
      delegate: _MenuLayout(anchor),
      child: ValueListenableBuilder(
        valueListenable: _voices.playing,
        builder: (context, _, _) => HighlightMenu(
          color: open?.color,
          note: open?.note ?? '',
          onColor: (c) => unawaited(_color(c)),
          onNote: () => unawaited(_note()),
          onCopy: () => unawaited(_copy()),
          onRecord: () => unawaited(_recordVoice()),
          onRemove: open == null ? null : () => unawaited(_remove()),
          voiceLength: open != null && open.hasVoice ? open.voiceLength : null,
          voicePlaying: open != null && _isPlaying(open),
          onPlayVoice: open == null ? null : () => unawaited(_playVoice(open)),
          onDeleteVoice: () => unawaited(_deleteVoice()),
        ),
      ),
    );
  }

  Future<void> _showDisplaySettings(ReaderSession session) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      // Taller than half the window: it scrolls past that.
      isScrollControlled: true,
      // The page stays as it is, to see each choice on it.
      barrierColor: Colors.transparent,
      constraints: const BoxConstraints(maxWidth: 480),
      builder: (_) => DisplaySheet(reflowable: session.document.reflowable),
    );
    _focus.requestFocus();
  }

  /// An EPUB's page: the shape of a book's, between 0.55 and 0.72 (wide
  /// enough for comfortable lines on a phone, not a wall of text on a
  /// desktop), as large as fits in [room] (the space one page gets).
  static double _reflowAspect(Size room) {
    if (room.isEmpty) return 2 / 3;
    return room.aspectRatio.clamp(0.55, 0.72);
  }

  /// The sheet an EPUB is laid out for, in [room].
  static Size _reflowSheet(Size room) {
    final aspect = _reflowAspect(room);
    final width = room.width / room.height > aspect
        ? room.height * aspect
        : room.width;
    return Size(width, width / aspect);
  }

  /// Where an EPUB's text does not go on a sheet that is the whole screen,
  /// [width] wide: under the system's bars and the notch, and past
  /// [ReaderScreen.maxLineWidth]. The same on both sides, so the text stays
  /// in the middle.
  static EdgeInsets _keepClear(EdgeInsets system, double width) {
    final side = [
      system.left + ReaderScreen._clearance,
      system.right + ReaderScreen._clearance,
      (width - ReaderScreen.maxLineWidth) / 2,
    ].reduce(math.max);
    return EdgeInsets.fromLTRB(
      side,
      system.top + ReaderScreen._clearance,
      side,
      system.bottom + ReaderScreen._clearance,
    );
  }

  /// The sheet last asked for (an EPUB): its size, and where its text does
  /// not go. A rebuild asks only on a change.
  (Size, EdgeInsets)? _laidOutFor;

  Widget _reading(BuildContext context, ReaderSession session) {
    if (!_focusAsked) {
      _focusAsked = true;
      // On touch the book opens full screen, without the bars (a tap in the
      // middle brings them). Only now that there is a book: while it loads,
      // or fails to, the system's bars stay.
      final fullScreen = isTouch(context);
      _chromeVisible = !fullScreen;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _focus.requestFocus();
        if (fullScreen) _showChrome(false);
      });
    }
    return Focus(
      focusNode: _focus,
      autofocus: true,
      onKeyEvent: (_, event) => _onKey(session, event),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final document = session.document;
          final touch = isTouch(context);
          // The page over the whole screen, the bars coming over it: always
          // on touch, in full screen with a mouse.
          final bleed = touch || _fullScreen;
          final system = touch ? _systemInsets(context) : EdgeInsets.zero;
          final around = bleed
              ? system + ReaderScreen.touchMargin
              : ReaderScreen.margin;
          final room = around.deflateSize(constraints.biggest);
          final twoPages =
              session.pageCount > 0 &&
              showsTwoPages(
                _prefs.layout,
                room,
                document.reflowable
                    ? 0.72
                    : document.pageAspectRatio(session.page),
                small:
                    WindowSize.of(context) == WindowSize.compact ||
                    WindowSize.isShort(context),
              );
          final spreads = Spreads(session.pageCount, twoPages: twoPages);
          final spread = spreads.of(session.page);
          _spreads = spreads;
          _spread = spread;
          _shown = session;
          // Turned away from the selection: it is gone.
          if (_selectionPage case final p?
              when p != spreads.left(spread) && p != spreads.right(spread)) {
            _clearSelection();
          }
          // One page: the sheet is the whole screen, no desk.
          final fills = bleed && !twoPages;
          final margin = fills ? EdgeInsets.zero : around;
          // The space each page gets.
          final pageRoom = twoPages ? Size(room.width / 2, room.height) : room;
          if (document.reflowable) {
            final sheet = fills ? constraints.biggest : _reflowSheet(pageRoom);
            final keepClear = fills
                ? _keepClear(system, sheet.width)
                : EdgeInsets.zero;
            // Pages are cut for the sheet once its size is known (after
            // this frame: state cannot change while building).
            if ((sheet, keepClear) != _laidOutFor && !sheet.isEmpty) {
              _laidOutFor = (sheet, keepClear);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) _controller.layout(sheet, keepClear: keepClear);
              });
            }
          }
          final pageAspect = document.reflowable
              ? _reflowAspect(pageRoom)
              : session.pageCount == 0
              ? 1.0
              : document.pageAspectRatio(
                  spreads.right(spread) ?? spreads.left(spread)!,
                );
          final colors = _theme.pageColors;
          // The sheet that turns: the page, or with two pages the one on the
          // right, bound at the spine, turning over onto the left one.
          final curl = session.pageCount == 0
              ? const SizedBox.shrink()
              : PageCurlView(
                  key: _curl,
                  pageCount: spreads.count,
                  page: spread,
                  paper: colors.paper,
                  // New colours or a new layout: new pictures too.
                  layoutVersion: Object.hash(
                    document.layoutVersion,
                    colors,
                    spreads,
                    Object.hashAll(session.highlights),
                  ),
                  // A mouse dragged over text selects it.
                  turnsOnDrag: (event) => !_selectsOnDrag(event),
                  sheetBuilder: (index) => KeyedSubtree(
                    key: index == spread ? ReaderScreen.pages : null,
                    child: KeyedSubtree(
                      key: index == spread ? _right : null,
                      child: _sheet(session, spreads.right(index), colors),
                    ),
                  ),
                  leftBuilder: !twoPages
                      ? null
                      : (index) => switch (spreads.left(index)) {
                          final page? when index == spread => KeyedSubtree(
                            key: _left,
                            child: KeyedSubtree(
                              key: ReaderScreen.leftPage,
                              child: _sheet(session, page, colors),
                            ),
                          ),
                          final page? => _sheet(session, page, colors),
                          // The cover: nothing on its left.
                          null => const SizedBox.shrink(),
                        },
                  leftImage: !twoPages
                      ? null
                      : (index, size, ratio) async =>
                            switch (spreads.left(index)) {
                              final page? => sheetImage(
                                session,
                                page,
                                size,
                                ratio,
                                colors,
                                _highlightMarks(session),
                              ),
                              null => null,
                            },
                  sheetImage: (index, size, ratio) =>
                      switch (spreads.right(index)) {
                        final page? => sheetImage(
                          session,
                          page,
                          size,
                          ratio,
                          colors,
                          _highlightMarks(session),
                        ),
                        null => blankSheetImage(size, ratio, colors.paper),
                      },
                  onTurned: (index) => _controller.goTo(
                    spreads.first(index),
                    through: spreads.last(index),
                  ),
                );
          // Text is selected with a mouse drag (a drag on the margin still
          // turns the page), or held and dragged on touch.
          final pages = !document.selectable
              ? curl
              : RawGestureDetector(
                  behavior: HitTestBehavior.translucent,
                  gestures: {
                    FilteredPan:
                        GestureRecognizerFactoryWithHandlers<FilteredPan>(
                          () => FilteredPan(debugOwner: this),
                          _setUpSelectDrag,
                        ),
                    LongPressGestureRecognizer:
                        GestureRecognizerFactoryWithHandlers<
                          LongPressGestureRecognizer
                        >(
                          () => LongPressGestureRecognizer(debugOwner: this),
                          _setUpSelectPress,
                        ),
                  },
                  child: curl,
                );
          final menu = _menu(session);
          return Stack(
            key: _stack,
            fit: StackFit.expand,
            children: [
              // Sees every touch without taking part in deciding what it is
              // (a tap, a page turn).
              Listener(
                onPointerSignal: _onPointerSignal,
                onPointerPanZoomStart: (_) => _swipeTurned = false,
                onPointerPanZoomUpdate: _onSwipe,
                onPointerDown: (_) {
                  _focus.requestFocus();
                  _dismissing = _menuRange != null;
                  if (_dismissing) setState(_clearSelection);
                },
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (details) {
                    if (_dismissing) return;
                    if (document.reflowable &&
                        _followLink(details.globalPosition)) {
                      return;
                    }
                    if (_highlightAt(details.globalPosition) case (
                      final page,
                      final highlight,
                    )) {
                      setState(() {
                        _clearSelection();
                        _selectionPage = page;
                        _openHighlight = highlight;
                      });
                      return;
                    }
                    final x = details.localPosition.dx / constraints.maxWidth;
                    if (x < ReaderScreen.edge) {
                      _previous();
                    } else if (x > 1 - ReaderScreen.edge) {
                      _next();
                    } else {
                      _showChrome(!_chromeVisible);
                    }
                  },
                  // The sheet: the whole screen (a page of another shape
                  // fits in it, its paper around); or the page's shape, as
                  // large as fits, on the desk; with two, side by side as an
                  // open book.
                  child: fills
                      ? pages
                      : Padding(
                          padding: margin,
                          child: Center(
                            child: AspectRatio(
                              aspectRatio: twoPages
                                  ? pageAspect * 2
                                  : pageAspect,
                              child: pages,
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
                  child: ReaderChrome(
                    session: session,
                    shown: session.pageCount == 0
                        ? null
                        : (spreads.first(spread), spreads.last(spread)),
                    onBack: () => unawaited(_close()),
                    onSeek: _controller.goTo,
                    onContents: () => _scaffold.currentState?.openDrawer(),
                    onBookmark: () => unawaited(_controller.toggleBookmark()),
                    onDisplay: () => unawaited(_showDisplaySettings(session)),
                    fullScreen: _fullScreen,
                    onFullScreen: _toggleFullScreen,
                  ),
                ),
              ),
              if (session.linkedFrom case final from?)
                Positioned(
                  left: 0,
                  right: 0,
                  // Above the bottom bar, shown or not (on touch it comes
                  // over the page: above the system's bars too).
                  bottom:
                      math.max(
                        margin.bottom,
                        _insets.bottom + ReaderScreen.margin.bottom,
                      ) +
                      8,
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
              ?menu,
            ],
          );
        },
      ),
    );
  }
}

/// Blank paper as an image of [size] at [pixelRatio]: the back of the book,
/// turning over its last page.
Future<ui.Image> blankSheetImage(Size size, double pixelRatio, Color paper) {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawColor(paper, BlendMode.src);
  final picture = recorder.endRecording();
  return picture
      .toImage(
        (size.width * pixelRatio).round(),
        (size.height * pixelRatio).round(),
      )
      .whenComplete(picture.dispose);
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
  List<PageMark> marks = const [],
]) async {
  final area = Offset.zero & size;
  final page = await session.document.pageImage(
    index,
    Size(area.width * pixelRatio, area.height * pixelRatio),
    colors,
    marks: marks,
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

/// Puts the highlight menu over [anchor] (the text it is for), or under it
/// when there is no room above, always inside the screen.
class _MenuLayout extends SingleChildLayoutDelegate {
  _MenuLayout(this.anchor);

  final Rect anchor;
  static const _gap = 8.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      constraints.loosen().deflate(const EdgeInsets.all(_gap));

  @override
  Offset getPositionForChild(Size size, Size child) {
    final x = (anchor.center.dx - child.width / 2)
        .clamp(_gap, math.max(_gap, size.width - child.width - _gap))
        .toDouble();
    final above = anchor.top - child.height - _gap;
    final below = anchor.bottom + _gap;
    final y = above >= _gap
        ? above
        : below + child.height <= size.height - _gap
        ? below
        : (size.height - child.height) / 2;
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_MenuLayout old) => old.anchor != anchor;
}

/// Writes a highlight's note: the text on Save, null on Cancel.
class _NoteDialog extends StatefulWidget {
  const _NoteDialog({required this.initial});

  final String initial;

  @override
  State<_NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<_NoteDialog> {
  late final _text = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.note),
      content: SizedBox(
        width: 400,
        child: TextField(
          key: ReaderScreen.noteField,
          controller: _text,
          autofocus: true,
          minLines: 3,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: l10n.noteHint,
            border: const OutlineInputBorder(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_text.text),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}

/// While a voice note records: the time so far, Cancel and Save. Pops true
/// to keep it; at [limit] it is kept on its own.
class _RecordingDialog extends StatefulWidget {
  const _RecordingDialog({required this.limit});

  final Duration limit;

  @override
  State<_RecordingDialog> createState() => _RecordingDialogState();
}

class _RecordingDialogState extends State<_RecordingDialog> {
  // Counted in ticks, not read from a clock: the same in tests.
  int _seconds = 0;
  late final Timer _tick = Timer.periodic(const Duration(seconds: 1), (_) {
    setState(() => _seconds++);
    if (_seconds >= widget.limit.inSeconds) Navigator.of(context).pop(true);
  });

  @override
  void initState() {
    super.initState();
    _tick; // Starts counting.
  }

  @override
  void dispose() {
    _tick.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.recording),
      content: Row(
        children: [
          Icon(Icons.mic, color: Theme.of(context).colorScheme.error),
          const SizedBox(width: 12),
          Text(
            clockText(Duration(seconds: _seconds)),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          key: ReaderScreen.saveRecordingButton,
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
