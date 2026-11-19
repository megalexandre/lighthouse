// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trickplay_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TrickplayInfo _$TrickplayInfoFromJson(Map<String, dynamic> json) =>
    _TrickplayInfo(
      width: (json['Width'] as num).toInt(),
      height: (json['Height'] as num).toInt(),
      tileWidth: (json['TileWidth'] as num).toInt(),
      tileHeight: (json['TileHeight'] as num).toInt(),
      thumbnailCount: (json['ThumbnailCount'] as num).toInt(),
      interval: (json['Interval'] as num).toInt(),
    );

const _$TrickplayInfoFieldMap = <String, String>{
  'width': 'Width',
  'height': 'Height',
  'tileWidth': 'TileWidth',
  'tileHeight': 'TileHeight',
  'thumbnailCount': 'ThumbnailCount',
  'interval': 'Interval',
};

Map<String, dynamic> _$TrickplayInfoToJson(_TrickplayInfo instance) =>
    <String, dynamic>{
      'Width': instance.width,
      'Height': instance.height,
      'TileWidth': instance.tileWidth,
      'TileHeight': instance.tileHeight,
      'ThumbnailCount': instance.thumbnailCount,
      'Interval': instance.interval,
    };
