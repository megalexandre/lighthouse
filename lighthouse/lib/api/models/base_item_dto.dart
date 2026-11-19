import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';
import 'chapter_info.dart';
import 'media_stream.dart';
import 'trickplay_info.dart';
import 'user_item_data_dto.dart';

part 'base_item_dto.freezed.dart';
part 'base_item_dto.g.dart';

/// What an item is. Only the kinds the app treats differently are listed;
/// anything else parses as [unknown].
@JsonEnum(fieldRename: FieldRename.pascal)
enum BaseItemKind {
  movie,
  series,
  season,
  episode,
  musicAlbum,
  musicArtist,
  audio,
  collectionFolder,
  folder,
  boxSet,
  userView,
  video,
  book,
  unknown;

  /// The name the server uses, e.g. MusicAlbum.
  String get jsonValue => _$BaseItemKindEnumMap[this]!;

  /// Opens as a grid of children (library screen) rather than a detail page.
  bool get isFolder => switch (this) {
    collectionFolder || folder || boxSet || userView => true,
    _ => false,
  };
}

/// An item of any kind (movie, series, episode, library...), with only the
/// fields the app reads. Lists return few fields; `GET /Items/{id}` returns
/// all of them, [overview] included.
@freezed
abstract class BaseItemDto with _$BaseItemDto {
  const factory BaseItemDto({
    required String id,
    required String name,
    @JsonKey(unknownEnumValue: BaseItemKind.unknown) required BaseItemKind type,

    /// For libraries: movies, tvshows, music, boxsets...
    String? collectionType,
    String? overview,
    int? productionYear,
    String? officialRating,

    /// Length in ticks (see core/ticks.dart).
    int? runTimeTicks,

    /// Episode / track number, and the season / disc it belongs to.
    int? indexNumber,
    int? parentIndexNumber,
    String? seriesId,
    String? seriesName,
    String? seasonId,
    String? seasonName,
    String? seriesPrimaryImageTag,
    String? albumArtist,

    /// For a track: its album, and the album's cover.
    String? albumId,
    String? album,
    String? albumPrimaryImageTag,

    /// Image type (Primary, Thumb, Logo...) → tag, which changes when the
    /// image does; it goes in the image URL so caches stay right.
    @Default({}) Map<String, String> imageTags,
    @Default([]) List<String> backdropImageTags,
    UserItemDataDto? userData,
    int? childCount,

    /// The file's tracks (video, audio, subtitles): only on the full item
    /// (`GET /Items/{id}`), for its technical badges.
    @Default([]) List<MediaStream> mediaStreams,

    /// A video's chapters, in order (full item only).
    @Default([]) List<ChapterInfo> chapters,

    /// Seek-bar thumbnails: media source id → picture width → how they are
    /// stored (full item only; empty when the server made none).
    @Default({}) Map<String, Map<String, TrickplayInfo>> trickplay,
  }) = _BaseItemDto;

  const BaseItemDto._();

  factory BaseItemDto.fromJson(Map<String, dynamic> json) =>
      _$BaseItemDtoFromJson(json);

  static const jsonShape = JsonShape(
    _$BaseItemDtoFieldMap,
    nested: {
      'UserData': UserItemDataDto.jsonShape,
      'MediaStreams': MediaStream.jsonShape,
      'Chapters': ChapterInfo.jsonShape,
      'Trickplay': TrickplayInfo.jsonShape,
    },
  );

  String? get primaryImageTag => imageTags['Primary'];
}
