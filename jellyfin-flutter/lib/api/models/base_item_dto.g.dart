// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_item_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_BaseItemDto _$BaseItemDtoFromJson(Map<String, dynamic> json) => _BaseItemDto(
  id: json['Id'] as String,
  name: json['Name'] as String,
  type: $enumDecode(
    _$BaseItemKindEnumMap,
    json['Type'],
    unknownValue: BaseItemKind.unknown,
  ),
  collectionType: json['CollectionType'] as String?,
  overview: json['Overview'] as String?,
  productionYear: (json['ProductionYear'] as num?)?.toInt(),
  officialRating: json['OfficialRating'] as String?,
  runTimeTicks: (json['RunTimeTicks'] as num?)?.toInt(),
  indexNumber: (json['IndexNumber'] as num?)?.toInt(),
  parentIndexNumber: (json['ParentIndexNumber'] as num?)?.toInt(),
  seriesId: json['SeriesId'] as String?,
  seriesName: json['SeriesName'] as String?,
  seasonId: json['SeasonId'] as String?,
  seasonName: json['SeasonName'] as String?,
  seriesPrimaryImageTag: json['SeriesPrimaryImageTag'] as String?,
  albumArtist: json['AlbumArtist'] as String?,
  albumId: json['AlbumId'] as String?,
  album: json['Album'] as String?,
  albumPrimaryImageTag: json['AlbumPrimaryImageTag'] as String?,
  imageTags:
      (json['ImageTags'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const {},
  backdropImageTags:
      (json['BackdropImageTags'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  userData: json['UserData'] == null
      ? null
      : UserItemDataDto.fromJson(json['UserData'] as Map<String, dynamic>),
  childCount: (json['ChildCount'] as num?)?.toInt(),
  mediaStreams:
      (json['MediaStreams'] as List<dynamic>?)
          ?.map((e) => MediaStream.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  chapters:
      (json['Chapters'] as List<dynamic>?)
          ?.map((e) => ChapterInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  trickplay:
      (json['Trickplay'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          (e as Map<String, dynamic>).map(
            (k, e) =>
                MapEntry(k, TrickplayInfo.fromJson(e as Map<String, dynamic>)),
          ),
        ),
      ) ??
      const {},
);

const _$BaseItemDtoFieldMap = <String, String>{
  'id': 'Id',
  'name': 'Name',
  'type': 'Type',
  'collectionType': 'CollectionType',
  'overview': 'Overview',
  'productionYear': 'ProductionYear',
  'officialRating': 'OfficialRating',
  'runTimeTicks': 'RunTimeTicks',
  'indexNumber': 'IndexNumber',
  'parentIndexNumber': 'ParentIndexNumber',
  'seriesId': 'SeriesId',
  'seriesName': 'SeriesName',
  'seasonId': 'SeasonId',
  'seasonName': 'SeasonName',
  'seriesPrimaryImageTag': 'SeriesPrimaryImageTag',
  'albumArtist': 'AlbumArtist',
  'albumId': 'AlbumId',
  'album': 'Album',
  'albumPrimaryImageTag': 'AlbumPrimaryImageTag',
  'imageTags': 'ImageTags',
  'backdropImageTags': 'BackdropImageTags',
  'userData': 'UserData',
  'childCount': 'ChildCount',
  'mediaStreams': 'MediaStreams',
  'chapters': 'Chapters',
  'trickplay': 'Trickplay',
};

Map<String, dynamic> _$BaseItemDtoToJson(_BaseItemDto instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'Type': _$BaseItemKindEnumMap[instance.type]!,
      'CollectionType': ?instance.collectionType,
      'Overview': ?instance.overview,
      'ProductionYear': ?instance.productionYear,
      'OfficialRating': ?instance.officialRating,
      'RunTimeTicks': ?instance.runTimeTicks,
      'IndexNumber': ?instance.indexNumber,
      'ParentIndexNumber': ?instance.parentIndexNumber,
      'SeriesId': ?instance.seriesId,
      'SeriesName': ?instance.seriesName,
      'SeasonId': ?instance.seasonId,
      'SeasonName': ?instance.seasonName,
      'SeriesPrimaryImageTag': ?instance.seriesPrimaryImageTag,
      'AlbumArtist': ?instance.albumArtist,
      'AlbumId': ?instance.albumId,
      'Album': ?instance.album,
      'AlbumPrimaryImageTag': ?instance.albumPrimaryImageTag,
      'ImageTags': instance.imageTags,
      'BackdropImageTags': instance.backdropImageTags,
      'UserData': ?instance.userData?.toJson(),
      'ChildCount': ?instance.childCount,
      'MediaStreams': instance.mediaStreams.map((e) => e.toJson()).toList(),
      'Chapters': instance.chapters.map((e) => e.toJson()).toList(),
      'Trickplay': instance.trickplay.map(
        (k, e) => MapEntry(k, e.map((k, e) => MapEntry(k, e.toJson()))),
      ),
    };

const _$BaseItemKindEnumMap = {
  BaseItemKind.movie: 'Movie',
  BaseItemKind.series: 'Series',
  BaseItemKind.season: 'Season',
  BaseItemKind.episode: 'Episode',
  BaseItemKind.musicAlbum: 'MusicAlbum',
  BaseItemKind.musicArtist: 'MusicArtist',
  BaseItemKind.audio: 'Audio',
  BaseItemKind.collectionFolder: 'CollectionFolder',
  BaseItemKind.folder: 'Folder',
  BaseItemKind.boxSet: 'BoxSet',
  BaseItemKind.userView: 'UserView',
  BaseItemKind.video: 'Video',
  BaseItemKind.book: 'Book',
  BaseItemKind.unknown: 'Unknown',
};
