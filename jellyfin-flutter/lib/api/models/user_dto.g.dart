// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserDto _$UserDtoFromJson(Map<String, dynamic> json) => _UserDto(
  id: json['Id'] as String,
  name: json['Name'] as String,
  serverId: json['ServerId'] as String?,
  hasPassword: json['HasPassword'] as bool?,
  configuration: json['Configuration'] == null
      ? null
      : UserConfiguration.fromJson(
          json['Configuration'] as Map<String, dynamic>,
        ),
);

const _$UserDtoFieldMap = <String, String>{
  'id': 'Id',
  'name': 'Name',
  'serverId': 'ServerId',
  'hasPassword': 'HasPassword',
  'configuration': 'Configuration',
};

Map<String, dynamic> _$UserDtoToJson(_UserDto instance) => <String, dynamic>{
  'Id': instance.id,
  'Name': instance.name,
  'ServerId': ?instance.serverId,
  'HasPassword': ?instance.hasPassword,
  'Configuration': ?instance.configuration?.toJson(),
};
