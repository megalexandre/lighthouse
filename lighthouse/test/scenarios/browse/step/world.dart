import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/core/failure.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

import '../../../support/fakes.dart';

/// What the steps of a scenario share: the app with its fake server and
/// library (see test/support/fakes.dart). Made by `the app is signed in`,
/// each scenario its own.
late TestApp app;

/// The scenario's tester, for the hooks: `Hooks.afterEach` closes the app
/// with it, and gets no tester of its own.
late WidgetTester tester;

/// How the fake library fails, in the steps that make it fail.
const unreachable = ServerUnreachable(testUrl);

/// The item of the fake library with that name.
BaseItemDto itemNamed(String name) => [
  ...TestItems.views,
  ...app.library.movies,
  TestItems.testShow,
  TestItems.season1,
  ...TestItems.episodes,
  TestItems.testAlbum,
  ...TestItems.tracks,
].firstWhere((i) => i.name == name);

/// The row of cards with that title.
Finder row(String title) =>
    find.byWidgetPredicate((w) => w is ItemRow && w.title == title);
