import 'package:flutter_test/flutter_test.dart';
import 'package:lighthouse/api/models/base_item_dto.dart';
import 'package:lighthouse/features/search/presentation/search_screen.dart';
import 'package:lighthouse/router.dart';

import '../../support/fakes.dart';

// What a user does in search is in test/scenarios/search/search.feature.
// Here: how often the server is asked, which no user sees.
void main() {
  testWidgets('typing asks once, after the pause', (tester) async {
    final app = TestApp();
    await app.open(tester, Routes.search);
    for (final text in ['e', 'ep', 'epi']) {
      await tester.enterText(find.byKey(SearchScreen.field), text);
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(SearchScreen.debounce);
    await tester.pumpAndSettle();
    expect(app.library.searches, ['epi']);
    expect(find.byKey(SearchScreen.row(BaseItemKind.episode)), findsOneWidget);
  });
}
