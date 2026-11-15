import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';
import 'user_dto.dart';

part 'authentication_result.freezed.dart';
part 'authentication_result.g.dart';

/// Response of `POST /Users/AuthenticateByName`.
@freezed
abstract class AuthenticationResult with _$AuthenticationResult {
  const factory AuthenticationResult({
    required UserDto user,
    required String accessToken,
    required String serverId,
  }) = _AuthenticationResult;

  factory AuthenticationResult.fromJson(Map<String, dynamic> json) =>
      _$AuthenticationResultFromJson(json);

  static const jsonShape = JsonShape(
    _$AuthenticationResultFieldMap,
    nested: {'User': UserDto.jsonShape},
  );
}
