import 'package:material_ui/material_ui.dart';

/// Whether the app is driven by touch (a phone, a tablet) instead of a mouse
/// and keyboard. It follows the platform, not the window's size: a narrow
/// desktop window still has a mouse, and a phone has no hover. Tests choose
/// it with `debugDefaultTargetPlatformOverride` (`usePhone` in the fakes).
///
/// It decides the interaction (hover, gestures, the size of what is
/// grabbed); the window's size ([WindowSize]) decides the layout.
bool isTouch(BuildContext context) => switch (Theme.of(context).platform) {
  TargetPlatform.android ||
  TargetPlatform.iOS ||
  TargetPlatform.fuchsia => true,
  TargetPlatform.linux ||
  TargetPlatform.macOS ||
  TargetPlatform.windows => false,
};

/// The least a touch target measures on a side (Material, Android).
const touchTarget = 48.0;
