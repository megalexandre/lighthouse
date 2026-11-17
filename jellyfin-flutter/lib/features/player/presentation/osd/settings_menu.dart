import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../core/failure.dart';
import '../../../../core/theme/app_tokens.dart';

/// A choice in a [SettingsMenu] page: [value] (null: "off"), its label and
/// an optional detail ("SRT", "Forced").
typedef MenuChoice<T> = ({T value, String label, String? detail, Key key});

/// What the menu shows.
enum SettingsPage { root, audio, subtitles, speed }

/// The player's settings panel (the design system's SettingsMenu): Audio,
/// Subtitles and Speed, each opening a page of single choices that takes
/// the panel's place ("‹ Subtitles" leads back). The chosen one has a
/// check in `osd-accent`. Choosing closes the panel.
class SettingsMenu extends StatefulWidget {
  const SettingsMenu({
    super.key,
    required this.audio,
    required this.selectedAudio,
    required this.onAudio,
    required this.subtitles,
    required this.selectedSubtitle,
    required this.onSubtitle,
    required this.rate,
    required this.onRate,
    required this.onClose,
    this.initialPage = SettingsPage.root,
  });

  static const width = 280.0;
  static const audioRow = Key('player.audio');
  static const subtitlesRow = Key('player.settings.subtitles');
  static const speedRow = Key('player.settings.speed');
  static const backRow = Key('player.settings.back');
  static Key speedItem(double rate) => Key('player.speed.$rate');

  /// The speeds offered.
  static const rates = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  final List<MenuChoice<int>> audio;
  final int? selectedAudio;
  final void Function(int index) onAudio;

  /// The first choice is usually "Off" (value null).
  final List<MenuChoice<int?>> subtitles;
  final int? selectedSubtitle;
  final void Function(int? index) onSubtitle;

  final double rate;
  final void Function(double rate) onRate;
  final VoidCallback onClose;
  final SettingsPage initialPage;

  @override
  State<SettingsMenu> createState() => SettingsMenuState();
}

/// "1×", "1.5×".
String rateLabel(double rate) => rate == 1
    ? 'Normal'
    : '${rate.toString().replaceAll(RegExp(r'\.0$'), '')}×';

class SettingsMenuState extends State<SettingsMenu> {
  late SettingsPage _page = widget.initialPage;

  SettingsPage get page => _page;

  /// Esc: one level up. False when already at the top (the caller closes).
  bool back() {
    if (_page == SettingsPage.root) return false;
    setState(() => _page = SettingsPage.root);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      width: SettingsMenu.width,
      padding: EdgeInsets.symmetric(vertical: tokens.space(2)),
      decoration: BoxDecoration(
        color: tokens.osdSurface,
        borderRadius: BorderRadius.circular(tokens.radiusLg),
        boxShadow: tokens.shadowMenu,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: switch (_page) {
            SettingsPage.root => _root(),
            SettingsPage.audio => _choices<int>(
              'Audio',
              widget.audio,
              widget.selectedAudio ?? -1,
              widget.onAudio,
            ),
            SettingsPage.subtitles => _choices(
              'Subtitles',
              widget.subtitles,
              widget.selectedSubtitle,
              widget.onSubtitle,
            ),
            SettingsPage.speed => _choices(
              'Speed',
              [
                for (final r in SettingsMenu.rates)
                  (
                    value: r,
                    label: rateLabel(r),
                    detail: null,
                    key: SettingsMenu.speedItem(r),
                  ),
              ],
              widget.rate,
              widget.onRate,
            ),
          },
        ),
      ),
    );
  }

  String _labelOf<T>(List<MenuChoice<T>> choices, T selected) =>
      choices.where((c) => c.value == selected).firstOrNull?.label ?? '';

  List<Widget> _root() => [
    if (widget.audio.length > 1)
      _Row(
        key: SettingsMenu.audioRow,
        label: 'Audio',
        value: _labelOf(widget.audio, widget.selectedAudio),
        autofocus: true,
        onTap: () => setState(() => _page = SettingsPage.audio),
      ),
    if (widget.subtitles.length > 1)
      _Row(
        key: SettingsMenu.subtitlesRow,
        label: 'Subtitles',
        value: _labelOf(widget.subtitles, widget.selectedSubtitle),
        autofocus: widget.audio.length <= 1,
        onTap: () => setState(() => _page = SettingsPage.subtitles),
      ),
    _Row(
      key: SettingsMenu.speedRow,
      label: 'Speed',
      value: rateLabel(widget.rate),
      autofocus: widget.audio.length <= 1 && widget.subtitles.length <= 1,
      onTap: () => setState(() => _page = SettingsPage.speed),
    ),
  ];

  List<Widget> _choices<T>(
    String title,
    List<MenuChoice<T>> choices,
    T selected,
    void Function(T) onChoose,
  ) {
    final tokens = context.tokens;
    return [
      _Row(
        key: SettingsMenu.backRow,
        label: title,
        leading: Icon(Icons.chevron_left, size: 20, color: tokens.osdInk),
        chevron: false,
        onTap: () => setState(() => _page = SettingsPage.root),
      ),
      Divider(height: 1, color: tokens.osdHover),
      SizedBox(height: tokens.space(1)),
      for (final c in choices)
        _Row(
          key: c.key,
          label: c.label,
          value: c.detail,
          chevron: false,
          selected: c.value == selected,
          autofocus: c.value == selected,
          leading: SizedBox(
            width: 20,
            child: c.value == selected
                ? Icon(Icons.check, size: 20, color: tokens.osdAccent)
                : null,
          ),
          onTap: () {
            onChoose(c.value);
            widget.onClose();
          },
        ),
    ];
  }
}

class _Row extends StatelessWidget {
  const _Row({
    super.key,
    required this.label,
    required this.onTap,
    this.value,
    this.leading,
    this.chevron = true,
    this.selected = false,
    this.autofocus = false,
  });

  final String label;
  final String? value;
  final Widget? leading;
  final bool chevron;
  final bool selected;
  final bool autofocus;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return InkWell(
      autofocus: autofocus,
      onTap: onTap,
      hoverColor: tokens.osdHover,
      focusColor: tokens.osdHover,
      highlightColor: tokens.osdHover,
      splashColor: Colors.transparent,
      child: SizedBox(
        height: 44,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: tokens.space(4)),
          child: Row(
            children: [
              if (leading != null) ...[
                leading!,
                SizedBox(width: tokens.space(3)),
              ],
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: selected ? tokens.osdAccent : tokens.osdInk,
                  ),
                ),
              ),
              if (value case final String v when v.isNotEmpty)
                Flexible(
                  child: Text(
                    v,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: tokens.osdInkMuted,
                    ),
                  ),
                ),
              if (chevron) ...[
                SizedBox(width: tokens.space(1)),
                Icon(Icons.chevron_right, size: 20, color: tokens.osdInk),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Closes [menu] on a click outside it: put it above everything else,
/// under the panel.
class MenuBarrier extends StatelessWidget {
  const MenuBarrier({super.key, required this.onDismiss});

  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onDismiss,
    onSecondaryTap: onDismiss,
    child: const SizedBox.expand(),
  );
}

/// Waits for [future]; on failure says so in a snack bar: the failure's
/// own message, or [fallback]. (A track that needs a new stream can fail,
/// the server gone: the old one keeps playing.)
void reportFailure(BuildContext context, Future<void> future, String fallback) {
  final messenger = ScaffoldMessenger.maybeOf(context);
  unawaited(
    future.catchError((Object e) {
      messenger?.showSnackBar(
        SnackBar(content: Text(e is Failure ? e.message : fallback)),
      );
    }),
  );
}
