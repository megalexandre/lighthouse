// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Session _$SessionFromJson(Map<String, dynamic> json) => _Session(
  server: ServerInfo.fromJson(json['Server'] as Map<String, dynamic>),
  userId: json['UserId'] as String,
  userName: json['UserName'] as String,
  token: json['Token'] as String,
);

const _$SessionFieldMap = <String, String>{
  'server': 'Server',
  'userId': 'UserId',
  'userName': 'UserName',
  'token': 'Token',
};

Map<String, dynamic> _$SessionToJson(_Session instance) => <String, dynamic>{
  'Server': instance.server.toJson(),
  'UserId': instance.userId,
  'UserName': instance.userName,
  'Token': instance.token,
};
