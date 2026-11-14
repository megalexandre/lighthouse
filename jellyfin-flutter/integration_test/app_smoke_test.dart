// Starts the real app (Linux, real plugins, libmpv loaded) under Xvfb.
// Run: xvfb-run -a flutter test integration_test -d linux
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jellyfin_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('Jellyfin'), findsOneWidget);
  });
}
