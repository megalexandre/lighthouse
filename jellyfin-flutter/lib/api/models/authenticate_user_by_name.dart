import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'authenticate_user_by_name.freezed.dart';
part 'authenticate_user_by_name.g.dart';

/// Body of `POST /Users/AuthenticateByName`.
@freezed
abstract class AuthenticateUserByName with _$AuthenticateUserByName {
  const factory AuthenticateUserByName({
    required String username,
    required String pw,
  }) = _AuthenticateUserByName;

  factory AuthenticateUserByName.fromJson(Map<String, dynamic> json) =>
      _$AuthenticateUserByNameFromJson(json);

  static const jsonShape = JsonShape(_$AuthenticateUserByNameFieldMap);
}
