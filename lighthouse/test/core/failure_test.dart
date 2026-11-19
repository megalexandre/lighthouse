import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/l10n/l10n.dart';
import 'package:material_ui/material_ui.dart';

import '../support/fakes.dart';

void main() {
  final pt = lookupAppLocalizations(const Locale('pt', 'BR'));

  test('a failure is worded for the user without its technical detail; the '
      'detail goes only to toString, which is what the log writes', () {
    const failures = <Failure>[
      PlayerError("MpvException: Failed to open 'http://x/stream'"),
      ServerError("type 'Null' is not a subtype of type 'String'"),
      StorageFailure('org.freedesktop.Secret.Error.IsLocked'),
    ];
    for (final failure in failures) {
      for (final l10n in [en, pt]) {
        expect(failure.describe(l10n), isNot(contains(failure.detail!)));
      }
      expect(failure.toString(), contains(failure.detail!));
    }
  });

  test('in the app language', () {
    const failure = Unauthorized();
    expect(failure.describe(en), 'Wrong username or password.');
    expect(failure.describe(pt), 'Usuário ou senha incorretos.');
  });

  test('a server error with a status says so', () {
    const failure = ServerError('HTTP 500', statusCode: 500);
    expect(failure.describe(en), 'The server answered with error 500.');
  });

  test('a bad certificate is named, since the user can act on it', () {
    const failure = ServerError(
      'invalid TLS certificate',
      badCertificate: true,
    );
    expect(
      failure.describe(en),
      "The server's security certificate is not valid.",
    );
  });

  test('anything that is not a Failure is "something went wrong"', () {
    expect(describeError(StateError('x'), en), 'Something went wrong.');
  });
}
