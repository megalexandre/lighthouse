import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/ticks.dart';
import '../../../../l10n/l10n.dart';
import '../../application/trickplay.dart';
import '../../data/player_engine.dart';

/// A chapter mark on the seek bar.
typedef SeekChapter = ({Duration start, String? name});

/// The player's progress bar (the design system's SeekBar): the track in
/// `osd-track`, what is loaded in `osd-buffer`, what was played in
/// `osd-accent`, cut by 2 px gaps where chapters start.
///
/// 4 px at rest; 6 px with a 14 px thumb while hovered, dragged or focused
/// (16 px of height to grab). Hovering shows a preview above the pointer:
/// the thumbnail there (when the server made them), the time and the
/// chapter's name. A drag seeks once, on release; a click seeks at once.
class SeekBar extends StatefulWidget {
  const SeekBar({
    super.key,
    required this.engine,
    this.chapters = const [],
    this.thumbnails,
    required this.onInteract,
  });

  final PlayerEngine engine;
  final List<SeekChapter> chapters;
  final TrickplayThumbnails? thumbnails;

  /// The user touched it (keeps the controls up).
  final VoidCallback onInteract;

  /// The preview's thumbnail size.
  static const previewWidth = 160.0;

  @override
  State<SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  late Duration _position = widget.engine.position;
  late Duration _duration = widget.engine.duration;
  late Duration _buffer = widget.engine.buffer;
  final _subscriptions = <StreamSubscription<Object?>>[];

  /// Where a drag is (ms), until release.
  double? _drag;

  /// The pointer over the bar (x in the bar), while it is.
  double? _hoverX;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    final e = widget.engine;
    _subscriptions.addAll([
      e.positionStream.listen((p) => setState(() => _position = p)),
      e.durationStream.listen((d) => setState(() => _duration = d)),
      e.bufferStream.listen((b) => setState(() => _buffer = b)),
    ]);
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    super.dispose();
  }

  double get _max => _duration.inMilliseconds.toDouble();

  Duration _timeAt(double x, double width) =>
      Duration(milliseconds: (x / width * _max).clamp(0, _max).round());

  void _seek(Duration to) {
    widget.onInteract();
    unawaited(widget.engine.seek(to));
  }

  /// The drag is at [x] of the bar's [width]; with [hover], the preview
  /// follows it.
  void _dragTo(double x, double width, {bool hover = false}) {
    setState(() {
      _drag = _timeAt(x, width).inMilliseconds.toDouble();
      if (hover) _hoverX = x;
    });
    widget.onInteract();
  }

  /// Released: one seek, to where the drag ended.
  Future<void> _endDrag() async {
    final to = _drag;
    if (to == null) return;
    await widget.engine.seek(Duration(milliseconds: to.round()));
    if (mounted) setState(() => _drag = null);
  }

  String? _chapterAt(Duration t) {
    String? name;
    for (final c in widget.chapters) {
      if (c.start <= t) name = c.name;
    }
    return name;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final active = _hoverX != null || _drag != null || _focused;
    final shown = _drag != null
        ? Duration(milliseconds: _drag!.round())
        : _position;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double fraction(Duration d) =>
            _max <= 0 ? 0 : (d.inMilliseconds / _max).clamp(0.0, 1.0);
        final bar = CustomPaint(
          size: Size(width, 16),
          painter: _TrackPainter(
            played: fraction(shown),
            buffered: fraction(_buffer),
            cuts: [
              for (final c in widget.chapters)
                if (c.start > Duration.zero) fraction(c.start),
            ],
            thick: active,
            thumb: active,
            track: tokens.osdTrack,
            buffer: tokens.osdBuffer,
            accent: tokens.osdAccent,
            ink: tokens.osdInk,
          ),
        );
        return Semantics(
          slider: true,
          label: context.l10n.seekPosition,
          value: _spoken(shown, _duration, context.l10n),
          child: Focus(
            onFocusChange: (f) => setState(() => _focused = f),
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              onHover: (e) => setState(() => _hoverX = e.localPosition.dx),
              onExit: (_) => setState(() => _hoverX = null),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: _max <= 0
                    ? null
                    : (d) => _seek(_timeAt(d.localPosition.dx, width)),
                onHorizontalDragStart: _max <= 0
                    ? null
                    : (d) => _dragTo(d.localPosition.dx, width),
                onHorizontalDragUpdate: _max <= 0
                    ? null
                    : (d) => _dragTo(d.localPosition.dx, width, hover: true),
                onHorizontalDragEnd: (_) => unawaited(_endDrag()),
                onHorizontalDragCancel: () => setState(() => _drag = null),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    bar,
                    if (_hoverX case final x? when _max > 0)
                      _preview(context, x.clamp(0.0, width), width),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _preview(BuildContext context, double x, double width) {
    final tokens = context.tokens;
    final at = _timeAt(x, width);
    final thumbnails = widget.thumbnails;
    final thumbnail = thumbnails?.at(at);
    if (thumbnails != null && thumbnail == null) {
      unawaited(
        thumbnails.load(at).then((t) {
          if (mounted && t != null) setState(() {});
        }),
      );
    }
    final chapter = _chapterAt(at);
    final boxWidth = SeekBar.previewWidth + 4;
    // Kept within the bar's ends.
    final left = (x - boxWidth / 2)
        .clamp(math.min(0.0, width - boxWidth), math.max(0.0, width - boxWidth))
        .toDouble();
    return Positioned(
      left: left,
      bottom: 22,
      width: boxWidth,
      child: IgnorePointer(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (thumbnails != null)
              Container(
                width: boxWidth,
                height: SeekBar.previewWidth / thumbnails.aspectRatio + 4,
                decoration: BoxDecoration(
                  color: tokens.osdSurface,
                  border: Border.all(color: tokens.osdInk, width: 2),
                  borderRadius: BorderRadius.circular(tokens.radiusSm),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                    math.max(0, tokens.radiusSm - 2),
                  ),
                  child: thumbnail == null
                      ? null
                      : CustomPaint(painter: _ThumbnailPainter(thumbnail)),
                ),
              ),
            const SizedBox(height: 4),
            Text(
              formatPosition(at),
              style: tokens.timecode.copyWith(
                color: tokens.osdInk,
                shadows: const [Shadow(blurRadius: 4)],
              ),
            ),
            if (chapter != null)
              Text(
                chapter,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: tokens.osdInkMuted,
                  shadows: const [Shadow(blurRadius: 4)],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// "23 minutes 41 seconds of 1 hour 52 minutes", for screen readers.
String _spoken(Duration at, Duration of, AppLocalizations l10n) {
  String words(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    return [
      if (h > 0) l10n.hours(h),
      if (m > 0) l10n.minutes(m),
      if (h == 0 && (s > 0 || m == 0)) l10n.seconds(s),
    ].join(' ');
  }

  return l10n.positionOf(words(at), words(of));
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    required this.played,
    required this.buffered,
    required this.cuts,
    required this.thick,
    required this.thumb,
    required this.track,
    required this.buffer,
    required this.accent,
    required this.ink,
  });

  /// Fractions of the length, 0..1.
  final double played;
  final double buffered;
  final List<double> cuts;
  final bool thick;
  final bool thumb;
  final Color track;
  final Color buffer;
  final Color accent;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final h = thick ? 6.0 : 4.0;
    final top = (size.height - h) / 2;
    final radius = Radius.circular(h / 2);
    RRect bar(double to) =>
        RRect.fromLTRBR(0, top, size.width * to, top + h, radius);

    // In a layer, so the chapter gaps can be cut out of all three.
    canvas
      ..saveLayer(Offset.zero & size, Paint())
      ..drawRRect(bar(1), Paint()..color = track)
      ..drawRRect(bar(math.max(buffered, played)), Paint()..color = buffer)
      ..drawRRect(bar(played), Paint()..color = accent);
    for (final cut in cuts) {
      canvas.drawRect(
        Rect.fromLTWH(size.width * cut - 1, top - 1, 2, h + 2),
        Paint()..blendMode = BlendMode.clear,
      );
    }
    canvas.restore();
    if (thumb) {
      canvas.drawCircle(
        Offset(size.width * played, size.height / 2),
        7,
        Paint()..color = ink,
      );
    }
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.played != played ||
      old.buffered != buffered ||
      old.thick != thick ||
      old.thumb != thumb ||
      old.cuts.length != cuts.length ||
      old.track != track ||
      old.accent != accent;
}

class _ThumbnailPainter extends CustomPainter {
  _ThumbnailPainter(this.thumbnail);

  final Thumbnail thumbnail;

  @override
  void paint(Canvas canvas, Size size) => canvas.drawImageRect(
    thumbnail.image,
    thumbnail.source,
    Offset.zero & size,
    Paint()..filterQuality = FilterQuality.medium,
  );

  @override
  bool shouldRepaint(_ThumbnailPainter old) =>
      old.thumbnail.image != thumbnail.image ||
      old.thumbnail.source != thumbnail.source;
}
