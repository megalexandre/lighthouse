import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';
import 'user_configuration.dart';

part 'user_dto.freezed.dart';
part 'user_dto.g.dart';

/// A user, as `GET /Users/Me` and the login response return it.
@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String name,
    String? serverId,
    bool? hasPassword,

    /// Only in `GET /Users/Me`.
    UserConfiguration? configuration,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) =>
      _$UserDtoFromJson(json);

  static const jsonShape = JsonShape(
    _$UserDtoFieldMap,
    nested: {'Configuration': UserConfiguration.jsonShape},
  );
}
