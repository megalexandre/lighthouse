import 'package:flutter_test/flutter_test.dart';

import '../../support/proxy.dart';
import 'i_am_signed_in_as_a_new_user.dart';
import 'world.dart' as world;

/// Usage: Given I am signed in as a new user through a proxy
///
/// The app only knows the proxy's address, so taking the proxy down takes
/// the server away.
Future<void> iAmSignedInAsANewUserThroughAProxy(WidgetTester tester) async {
  final proxy = world.proxy = await FlakyProxy.start(world.server.url);
  addTearDown(proxy.close);
  await signInAsANewUser(tester, url: proxy.url);
}
