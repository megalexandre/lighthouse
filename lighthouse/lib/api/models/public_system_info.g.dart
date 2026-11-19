// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_system_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicSystemInfo _$PublicSystemInfoFromJson(Map<String, dynamic> json) =>
    _PublicSystemInfo(
      id: json['Id'] as String,
      serverName: json['ServerName'] as String,
      version: json['Version'] as String,
      productName: json['ProductName'] as String?,
      startupWizardCompleted: json['StartupWizardCompleted'] as bool?,
    );

const _$PublicSystemInfoFieldMap = <String, String>{
  'id': 'Id',
  'serverName': 'ServerName',
  'version': 'Version',
  'productName': 'ProductName',
  'startupWizardCompleted': 'StartupWizardCompleted',
};

Map<String, dynamic> _$PublicSystemInfoToJson(_PublicSystemInfo instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'ServerName': instance.serverName,
      'Version': instance.version,
      'ProductName': ?instance.productName,
      'StartupWizardCompleted': ?instance.startupWizardCompleted,
    };
