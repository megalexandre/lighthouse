import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/app.dart';

void main() {
  testWidgets('app starts on the first screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: JellyfinApp()));
    await tester.pumpAndSettle();
    expect(find.text('Jellyfin'), findsOneWidget);
  });
}
