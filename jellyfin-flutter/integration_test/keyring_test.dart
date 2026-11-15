// The real keyring plugin (libsecret). In the dev container and on CI there
// is no reachable Secret Service, so this exercises the failure path; on a
// desktop with a keyring it exercises the normal one. Either way the app
// must not crash: the plugin reports errors as C++ exceptions, which used
// to abort the process before its own catch blocks ran.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/core/storage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const key = 'jellyfin-flutter-keyring-test';

  testWidgets('keyring errors come back as values, not crashes', (
    tester,
  ) async {
    final store = SecureKeyValueStore();

    // Reachable keyring: null (nothing stored). Unreachable: also null.
    expect(await store.read(key), isNull);

    try {
      await store.write(key, 'value');
      expect(await store.read(key), 'value');
    } on StorageFailure catch (e) {
      // No keyring here: reported, not fatal.
      expect(e.message, contains('keyring'));
    } finally {
      await store.delete(key);
    }
  });
}
