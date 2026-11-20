import 'package:flutter_test/flutter_test.dart';

import 'world.dart';

/// Usage: When the server is back
///
/// The proxy passes everything on again; nobody tells the app.
Future<void> theServerIsBack(WidgetTester tester) async {
  proxy.up = true;
}
