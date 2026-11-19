/// Client name sent to the server; shows up in the server's device list.
const clientName = 'Lighthouse';

/// Sent to the server with every request. Must match `version:` in
/// pubspec.yaml (test/core/config_test.dart checks it).
const appVersion = '0.1.0';

/// Address prefilled on the connect screen. Empty unless the build passes
/// `--dart-define=JELLYFIN_SERVER=<url>`, as the "Lighthouse (dev
/// server)" launch configuration does.
const defaultServerAddress = String.fromEnvironment('JELLYFIN_SERVER');
