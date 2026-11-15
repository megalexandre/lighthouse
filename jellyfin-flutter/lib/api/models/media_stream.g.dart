// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_stream.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MediaStream _$MediaStreamFromJson(Map<String, dynamic> json) => _MediaStream(
  index: (json['Index'] as num).toInt(),
  type: $enumDecode(
    _$MediaStreamTypeEnumMap,
    json['Type'],
    unknownValue: MediaStreamType.unknown,
  ),
  codec: json['Codec'] as String?,
  language: json['Language'] as String?,
  title: json['Title'] as String?,
  displayTitle: json['DisplayTitle'] as String?,
  isExternal: json['IsExternal'] as bool? ?? false,
  isDefault: json['IsDefault'] as bool? ?? false,
  isForced: json['IsForced'] as bool? ?? false,
  deliveryMethod: $enumDecodeNullable(
    _$SubtitleDeliveryMethodEnumMap,
    json['DeliveryMethod'],
    unknownValue: SubtitleDeliveryMethod.unknown,
  ),
  deliveryUrl: json['DeliveryUrl'] as String?,
  channels: (json['Channels'] as num?)?.toInt(),
);

const _$MediaStreamFieldMap = <String, String>{
  'index': 'Index',
  'type': 'Type',
  'codec': 'Codec',
  'language': 'Language',
  'title': 'Title',
  'displayTitle': 'DisplayTitle',
  'isExternal': 'IsExternal',
  'isDefault': 'IsDefault',
  'isForced': 'IsForced',
  'deliveryMethod': 'DeliveryMethod',
  'deliveryUrl': 'DeliveryUrl',
  'channels': 'Channels',
};

Map<String, dynamic> _$MediaStreamToJson(
  _MediaStream instance,
) => <String, dynamic>{
  'Index': instance.index,
  'Type': _$MediaStreamTypeEnumMap[instance.type]!,
  'Codec': ?instance.codec,
  'Language': ?instance.language,
  'Title': ?instance.title,
  'DisplayTitle': ?instance.displayTitle,
  'IsExternal': instance.isExternal,
  'IsDefault': instance.isDefault,
  'IsForced': instance.isForced,
  'DeliveryMethod': ?_$SubtitleDeliveryMethodEnumMap[instance.deliveryMethod],
  'DeliveryUrl': ?instance.deliveryUrl,
  'Channels': ?instance.channels,
};

const _$MediaStreamTypeEnumMap = {
  MediaStreamType.audio: 'Audio',
  MediaStreamType.video: 'Video',
  MediaStreamType.subtitle: 'Subtitle',
  MediaStreamType.embeddedImage: 'EmbeddedImage',
  MediaStreamType.data: 'Data',
  MediaStreamType.lyric: 'Lyric',
  MediaStreamType.unknown: 'Unknown',
};

const _$SubtitleDeliveryMethodEnumMap = {
  SubtitleDeliveryMethod.encode: 'Encode',
  SubtitleDeliveryMethod.embed: 'Embed',
  SubtitleDeliveryMethod.external: 'External',
  SubtitleDeliveryMethod.hls: 'Hls',
  SubtitleDeliveryMethod.drop: 'Drop',
  SubtitleDeliveryMethod.unknown: 'Unknown',
};
