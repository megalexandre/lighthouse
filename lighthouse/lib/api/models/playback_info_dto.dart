import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';
import 'device_profile.dart';

part 'playback_info_dto.freezed.dart';
part 'playback_info_dto.g.dart';

/// Body of `POST /Items/{id}/PlaybackInfo`.
@Freezed(toJson: true)
abstract class PlaybackInfoDto with _$PlaybackInfoDto {
  const factory PlaybackInfoDto({
    required String userId,
    required DeviceProfile deviceProfile,
    int? startTimeTicks,
    int? audioStreamIndex,
    int? subtitleStreamIndex,
    String? mediaSourceId,
    int? maxStreamingBitrate,
    @Default(true) bool autoOpenLiveStream,
  }) = _PlaybackInfoDto;

  static const jsonShape = JsonShape(
    _$PlaybackInfoDtoFieldMap,
    nested: {'DeviceProfile': DeviceProfile.jsonShape},
  );
}
