import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/features/auth/application/auth_controller.dart';
import 'package:jellyfin_flutter/router.dart';

import 'support/fakes.dart';

void main() {
  const loading = AsyncLoading<AuthState>();
  const noServer = AsyncData(AuthState());
  const signedOut = AsyncData(AuthState(server: testServer));
  const signedIn = AsyncData(
    AuthState(server: testServer, session: testSession),
  );

  const cases = [
    // (state, asked for, goes to; null = stays)
    (loading, Routes.home, Routes.splash),
    (loading, Routes.splash, null),
    (noServer, Routes.splash, Routes.connect),
    (noServer, Routes.home, Routes.connect),
    (noServer, Routes.login, Routes.connect),
    (noServer, Routes.connect, null),
    (signedOut, Routes.connect, Routes.login),
    (signedOut, Routes.home, Routes.login),
    (signedOut, Routes.login, null),
    (signedIn, Routes.splash, Routes.home),
    (signedIn, Routes.connect, Routes.home),
    (signedIn, Routes.login, Routes.home),
    (signedIn, Routes.home, null),
  ];

  for (final (state, location, expected) in cases) {
    final name = switch (state) {
      AsyncLoading() => 'loading',
      _ when state == noServer => 'no server',
      _ when state == signedOut => 'signed out',
      _ => 'signed in',
    };
    test('$name: $location → ${expected ?? 'stays'}', () {
      expect(authRedirect(state, location), expected);
    });
  }
}
