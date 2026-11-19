// Runs integration_test/ files on an AOT build (profile mode, compiled
// like release) through `flutter drive`: tool/profile_test.sh.
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
