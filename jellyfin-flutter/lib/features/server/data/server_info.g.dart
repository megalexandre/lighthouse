// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'server_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ServerInfo _$ServerInfoFromJson(Map<String, dynamic> json) => _ServerInfo(
  url: json['Url'] as String,
  id: json['Id'] as String,
  name: json['Name'] as String,
  version: json['Version'] as String,
);

const _$ServerInfoFieldMap = <String, String>{
  'url': 'Url',
  'id': 'Id',
  'name': 'Name',
  'version': 'Version',
};

Map<String, dynamic> _$ServerInfoToJson(_ServerInfo instance) =>
    <String, dynamic>{
      'Url': instance.url,
      'Id': instance.id,
      'Name': instance.name,
      'Version': instance.version,
    };
