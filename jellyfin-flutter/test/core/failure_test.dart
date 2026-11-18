import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/core/failure.dart';

void main() {
  test('a failure tells the user in plain words; the technical detail goes '
      'only to toString, which is what the log writes', () {
    const failures = <Failure>[
      PlayerError("MpvException: Failed to open 'http://x/stream'"),
      ServerError("type 'Null' is not a subtype of type 'String'"),
      StorageFailure('org.freedesktop.Secret.Error.IsLocked'),
    ];
    for (final failure in failures) {
      expect(failure.message, isNot(contains(failure.detail!)));
      expect(failure.toString(), contains(failure.detail!));
    }
  });

  test('a server error with a status says so', () {
    const failure = ServerError('HTTP 500', statusCode: 500);
    expect(failure.message, 'The server answered with error 500.');
  });

  test('a bad certificate is named, since the user can act on it', () {
    const failure = ServerError(
      'invalid TLS certificate',
      hint: "The server's security certificate is not valid.",
    );
    expect(failure.message, "The server's security certificate is not valid.");
  });
}
