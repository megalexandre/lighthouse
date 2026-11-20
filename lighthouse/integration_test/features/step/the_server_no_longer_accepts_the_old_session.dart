import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/auth/data/auth_repository.dart';

import 'world.dart';

/// Usage: And the server no longer accepts the old session
///
/// Signing out revoked the token on the server, not only in the app. The app
/// tells the server in the background, so this waits a little for it.
Future<void> theServerNoLongerAcceptsTheOldSession(WidgetTester tester) async {
  final auth = JellyfinAuthRepository(() async => probe);
  for (var tries = 0; tries < 50; tries++) {
    try {
      await auth.check(oldSession);
    } on Unauthorized {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
  fail('the server still accepts the session 5 s after signing out');
}
