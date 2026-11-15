import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'features/auth/application/auth_controller.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/server/presentation/connect_screen.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const connect = '/connect';
  static const login = '/login';
  static const home = '/';
}

/// Where [auth] lets the user be, given they asked for [location].
/// Null means "stay".
String? authRedirect(AsyncValue<AuthState> auth, String location) {
  final state = auth.value;
  final String target;
  if (state == null) {
    target = Routes.splash; // still restoring the session
  } else if (state.signedIn) {
    const signedOutOnly = {Routes.splash, Routes.connect, Routes.login};
    return signedOutOnly.contains(location) ? Routes.home : null;
  } else if (state.server == null) {
    target = Routes.connect;
  } else {
    target = Routes.login;
  }
  return location == target ? null : target;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(authControllerProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (context, state) =>
        authRedirect(ref.read(authControllerProvider), state.matchedLocation),
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const _Splash()),
      GoRoute(path: Routes.connect, builder: (_, _) => const ConnectScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen()),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) =>
      const Scaffold(body: Center(child: CircularProgressIndicator()));
}
