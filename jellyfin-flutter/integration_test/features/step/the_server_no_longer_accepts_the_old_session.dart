import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/core/failure.dart';
import 'package:jellyfin_flutter/features/auth/data/auth_repository.dart';

import 'world.dart';

/// Usage: And the server no longer accepts the old session
///
/// Signing out revoked the token on the server, not only in the app.
Future<void> theServerNoLongerAcceptsTheOldSession(WidgetTester tester) async {
  await expectLater(
    JellyfinAuthRepository(() async => probe).check(oldSession),
    throwsA(isA<Unauthorized>()),
  );
}
