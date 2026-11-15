// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'authentication_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuthenticationResult _$AuthenticationResultFromJson(
  Map<String, dynamic> json,
) => _AuthenticationResult(
  user: UserDto.fromJson(json['User'] as Map<String, dynamic>),
  accessToken: json['AccessToken'] as String,
  serverId: json['ServerId'] as String,
);

const _$AuthenticationResultFieldMap = <String, String>{
  'user': 'User',
  'accessToken': 'AccessToken',
  'serverId': 'ServerId',
};

Map<String, dynamic> _$AuthenticationResultToJson(
  _AuthenticationResult instance,
) => <String, dynamic>{
  'User': instance.user.toJson(),
  'AccessToken': instance.accessToken,
  'ServerId': instance.serverId,
};
