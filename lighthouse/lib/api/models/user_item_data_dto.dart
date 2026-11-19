import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'user_item_data_dto.freezed.dart';
part 'user_item_data_dto.g.dart';

/// The signed-in user's state for one item: watched, position, unwatched
/// children.
@freezed
abstract class UserItemDataDto with _$UserItemDataDto {
  const factory UserItemDataDto({
    @Default(0) int playbackPositionTicks,
    @Default(false) bool played,

    /// 0–100; only present while partly watched.
    double? playedPercentage,

    /// For series and seasons.
    int? unplayedItemCount,
  }) = _UserItemDataDto;

  factory UserItemDataDto.fromJson(Map<String, dynamic> json) =>
      _$UserItemDataDtoFromJson(json);

  static const jsonShape = JsonShape(_$UserItemDataDtoFieldMap);
}
