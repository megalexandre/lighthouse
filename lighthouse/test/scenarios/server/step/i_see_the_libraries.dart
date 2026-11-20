import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/features/home/presentation/home_screen.dart';

/// Usage: And I see the libraries
///
/// Home's first row.
Future<void> iSeeTheLibraries(WidgetTester tester) async {
  expect(find.byKey(HomeScreen.viewsRow), findsOneWidget);
}
