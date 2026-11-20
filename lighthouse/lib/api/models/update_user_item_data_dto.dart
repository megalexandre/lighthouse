import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'update_user_item_data_dto.freezed.dart';
part 'update_user_item_data_dto.g.dart';

/// Body of `POST /UserItems/{id}/UserData`: changes the user's state for
/// an item directly (a book's reading position), outside playback.
@Freezed(toJson: true)
abstract class UpdateUserItemDataDto with _$UpdateUserItemDataDto {
  const factory UpdateUserItemDataDto({
    int? playbackPositionTicks,
    bool? played,
  }) = _UpdateUserItemDataDto;

  static const jsonShape = JsonShape(_$UpdateUserItemDataDtoFieldMap);
}
