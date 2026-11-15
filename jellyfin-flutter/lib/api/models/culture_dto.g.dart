// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'culture_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CultureDto _$CultureDtoFromJson(Map<String, dynamic> json) => _CultureDto(
  displayName: json['DisplayName'] as String,
  threeLetterIsoLanguageName: json['ThreeLetterISOLanguageName'] as String?,
);

const _$CultureDtoFieldMap = <String, String>{
  'displayName': 'DisplayName',
  'threeLetterIsoLanguageName': 'ThreeLetterISOLanguageName',
};

Map<String, dynamic> _$CultureDtoToJson(_CultureDto instance) =>
    <String, dynamic>{
      'DisplayName': instance.displayName,
      'ThreeLetterISOLanguageName': ?instance.threeLetterIsoLanguageName,
    };
