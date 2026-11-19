import 'package:flutter_test/flutter_test.dart';

import 'i_read_it_again.dart';
import 'navigation.dart';

/// Usage: When I read {'Test Comic'} from {'Books'}
///
/// Home → the library → the book's page → Read.
Future<void> iReadFrom(WidgetTester tester, String name, String library) async {
  await openFromLibrary(tester, library, name);
  await iReadItAgain(tester);
}
