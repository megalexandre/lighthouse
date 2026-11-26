import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When I scroll up over the video
///
/// One notch of the mouse wheel, beside the video's middle.
Future<void> iScrollUpOverTheVideo(WidgetTester tester) =>
    scrollOverVideo(tester, const Offset(0, -20));
