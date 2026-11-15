// Parses JSON captured from a real Jellyfin 12.4 (test/fixtures/api).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/authenticate_user_by_name.dart';
import 'package:jellyfin_flutter/api/models/authentication_result.dart';
import 'package:jellyfin_flutter/api/models/public_system_info.dart';
import 'package:jellyfin_flutter/api/models/user_dto.dart';

Map<String, dynamic> fixture(String name) =>
    jsonDecode(File('test/fixtures/api/$name.json').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  test('PublicSystemInfo', () {
    final info = PublicSystemInfo.fromJson(fixture('system_info_public'));
    expect(info.id, isNotEmpty);
    expect(info.version, '12.4.0');
    expect(info.productName, 'Jellyfin Server');
    expect(info.startupWizardCompleted, isTrue);
  });

  test('AuthenticationResult', () {
    final result = AuthenticationResult.fromJson(
      fixture('authenticate_by_name'),
    );
    expect(result.accessToken, '0123456789abcdef0123456789abcdef');
    expect(result.user.name, 'alice');
    expect(result.user.id, isNotEmpty);
    expect(result.serverId, result.user.serverId);
  });

  test('UserDto', () {
    final user = UserDto.fromJson(fixture('users_me'));
    expect(user.name, 'alice');
    expect(user.hasPassword, isTrue);
  });

  test('AuthenticateUserByName uses the server field names', () {
    expect(
      const AuthenticateUserByName(username: 'alice', pw: 'secret').toJson(),
      {'Username': 'alice', 'Pw': 'secret'},
    );
  });

  test('a response missing a required field does not parse', () {
    final json = fixture('users_me')..remove('Id');
    expect(() => UserDto.fromJson(json), throwsA(isA<TypeError>()));
  });
}
