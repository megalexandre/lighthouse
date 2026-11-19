import '../../../support/fakes.dart';

/// What the steps of a scenario share: the app with its fake server and
/// its one user, alice / secret (see test/support/fakes.dart). Made by
/// `the app is connected to a server` or `the app is started for the first
/// time`, each scenario its own.
late TestApp app;
