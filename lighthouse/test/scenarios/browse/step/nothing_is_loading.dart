import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/widgets/skeleton.dart';
import 'package:material_ui/material_ui.dart';

/// Usage: And nothing is loading
Future<void> nothingIsLoading(WidgetTester tester) async {
  expect(find.byType(Skeleton), findsNothing);
  expect(find.byType(CircularProgressIndicator), findsNothing);
}
