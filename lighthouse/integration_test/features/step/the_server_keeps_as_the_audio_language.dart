import 'package:flutter_test/flutter_test.dart';

import '../../support/app.dart';
import 'world.dart';

/// Usage: Then the server keeps {'por'} as the audio language
///
/// In the user's configuration (saved in the background).
Future<void> theServerKeepsAsTheAudioLanguage(
  WidgetTester tester,
  String code,
) async {
  var saved = '';
  await waitUntil(
    tester,
    () => saved == code,
    reason: 'the server to keep "$code" (has "$saved")',
    poll: () async {
      final found = await server.adminGet<Map<String, dynamic>>(
        '/Users/${user.id}',
      );
      final config = found['Configuration'] as Map<String, dynamic>;
      saved = config['AudioLanguagePreference'] as String? ?? '';
    },
  );
}
