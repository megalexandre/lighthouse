import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';

part 'chapter_info.freezed.dart';
part 'chapter_info.g.dart';

/// A chapter of a video: where it starts (ticks) and its name.
@freezed
abstract class ChapterInfo with _$ChapterInfo {
  const factory ChapterInfo({
    @Default(0) int startPositionTicks,
    String? name,
  }) = _ChapterInfo;

  factory ChapterInfo.fromJson(Map<String, dynamic> json) =>
      _$ChapterInfoFromJson(json);

  static const jsonShape = JsonShape(_$ChapterInfoFieldMap);
}
