import 'package:freezed_annotation/freezed_annotation.dart';

import '../../server/data/server_info.dart';

part 'session.freezed.dart';
part 'session.g.dart';

/// A signed-in user on a server. Stored in the keyring between runs.
@freezed
abstract class Session with _$Session {
  const factory Session({
    required ServerInfo server,
    required String userId,
    required String userName,
    required String token,
  }) = _Session;

  factory Session.fromJson(Map<String, dynamic> json) =>
      _$SessionFromJson(json);
}
