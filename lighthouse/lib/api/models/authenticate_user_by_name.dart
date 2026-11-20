import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'authenticate_user_by_name.freezed.dart';
part 'authenticate_user_by_name.g.dart';

/// Body of `POST /Users/AuthenticateByName`.
@Freezed(toJson: true)
abstract class AuthenticateUserByName with _$AuthenticateUserByName {
  const factory AuthenticateUserByName({
    required String username,
    required String pw,
  }) = _AuthenticateUserByName;

  static const jsonShape = JsonShape(_$AuthenticateUserByNameFieldMap);
}
