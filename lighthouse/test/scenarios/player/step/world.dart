import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';

/// What the steps of a scenario share: the app with its fake server,
/// library, player... (see test/support/fakes.dart). Made by
/// `the app is signed in`, each scenario its own.
late TestApp app;

/// The scenario's tester, for the hooks: `Hooks.afterEach` closes the app
/// with it, and gets no tester of its own.
late WidgetTester tester;
