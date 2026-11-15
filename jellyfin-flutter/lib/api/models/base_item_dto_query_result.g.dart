// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_item_dto_query_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BaseItemDtoQueryResult _$BaseItemDtoQueryResultFromJson(
  Map<String, dynamic> json,
) => _BaseItemDtoQueryResult(
  items:
      (json['Items'] as List<dynamic>?)
          ?.map((e) => BaseItemDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  totalRecordCount: (json['TotalRecordCount'] as num?)?.toInt() ?? 0,
  startIndex: (json['StartIndex'] as num?)?.toInt() ?? 0,
);

const _$BaseItemDtoQueryResultFieldMap = <String, String>{
  'items': 'Items',
  'totalRecordCount': 'TotalRecordCount',
  'startIndex': 'StartIndex',
};

Map<String, dynamic> _$BaseItemDtoQueryResultToJson(
  _BaseItemDtoQueryResult instance,
) => <String, dynamic>{
  'Items': instance.items.map((e) => e.toJson()).toList(),
  'TotalRecordCount': instance.totalRecordCount,
  'StartIndex': instance.startIndex,
};
