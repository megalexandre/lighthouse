import 'package:flutter_test/flutter_test.dart';

import 'i_am_signed_in_as_a_new_user.dart';

/// Usage: Given I am signed in as a new user with the app as installed
///
/// As "I am signed in as a new user", but the app keeps its default
/// language (Brazilian Portuguese) instead of the tests' English.
Future<void> iAmSignedInAsANewUserWithTheAppAsInstalled(WidgetTester tester) =>
    signInAsANewUser(tester, asInstalled: true);
