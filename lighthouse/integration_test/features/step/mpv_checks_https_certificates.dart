import 'package:flutter_test/flutter_test.dart';

import '../../support/player.dart';

/// Usage: And mpv checks HTTPS certificates
///
/// The token goes with each request.
Future<void> mpvChecksHttpsCertificates(WidgetTester tester) async {
  expect(await mpvEngine(tester).mpvProperty('tls-verify'), 'yes');
}
