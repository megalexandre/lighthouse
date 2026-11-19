import 'package:flutter/widgets.dart';

/// How much room a layout has, in Material 3's window size classes (widths
/// in logical pixels). Screens ask for one of these instead of picking
/// their own widths, so every screen changes its layout at the same points.
///
/// Measure what the layout itself gets ([WindowSize.ofWidth] with a
/// LayoutBuilder's width) where a component can sit in a narrower space
/// than the window; the whole window ([WindowSize.of]) for a page's frame.
enum WindowSize implements Comparable<WindowSize> {
  /// A phone held upright: one column.
  compact,

  /// A tablet upright, an unfolded phone: two columns, a navigation rail.
  medium,

  /// A tablet on its side, a small desktop window: list and detail side by
  /// side, desktop bars.
  expanded,

  /// A desktop window.
  large,

  /// A large monitor or a TV: content keeps a maximum width.
  extraLarge;

  /// Where each class starts.
  static const mediumWidth = 600.0;
  static const expandedWidth = 840.0;
  static const largeWidth = 1200.0;
  static const extraLargeWidth = 1600.0;

  /// Below this height the window is short: a phone on its side, where bars
  /// above and below eat the picture.
  static const shortHeight = 480.0;

  static WindowSize ofWidth(double width) => switch (width) {
    < mediumWidth => compact,
    < expandedWidth => medium,
    < largeWidth => expanded,
    < extraLargeWidth => large,
    _ => extraLarge,
  };

  /// The window's class (rebuilds when its size changes).
  static WindowSize of(BuildContext context) =>
      ofWidth(MediaQuery.sizeOf(context).width);

  /// Whether the window is short (see [shortHeight]).
  static bool isShort(BuildContext context) =>
      MediaQuery.sizeOf(context).height < shortHeight;

  /// At least as roomy as [other].
  bool atLeast(WindowSize other) => index >= other.index;

  @override
  int compareTo(WindowSize other) => index - other.index;
}
