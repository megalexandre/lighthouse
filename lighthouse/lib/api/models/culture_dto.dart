import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'culture_dto.freezed.dart';
part 'culture_dto.g.dart';

/// A language the server knows, for the language pickers.
@freezed
abstract class CultureDto with _$CultureDto {
  const factory CultureDto({
    required String displayName,
    @JsonKey(name: 'ThreeLetterISOLanguageName')
    String? threeLetterIsoLanguageName,
  }) = _CultureDto;

  factory CultureDto.fromJson(Map<String, dynamic> json) =>
      _$CultureDtoFromJson(json);

  static const jsonShape = JsonShape(_$CultureDtoFieldMap);
}
