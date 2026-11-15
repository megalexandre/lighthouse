import 'package:freezed_annotation/freezed_annotation.dart';

import '../json_shape.dart';
import 'base_item_dto.dart';

part 'base_item_dto_query_result.freezed.dart';
part 'base_item_dto_query_result.g.dart';

/// One page of items, and how many there are in total.
@freezed
abstract class BaseItemDtoQueryResult with _$BaseItemDtoQueryResult {
  const factory BaseItemDtoQueryResult({
    @Default([]) List<BaseItemDto> items,
    @Default(0) int totalRecordCount,
    @Default(0) int startIndex,
  }) = _BaseItemDtoQueryResult;

  factory BaseItemDtoQueryResult.fromJson(Map<String, dynamic> json) =>
      _$BaseItemDtoQueryResultFromJson(json);

  static const jsonShape = JsonShape(
    _$BaseItemDtoQueryResultFieldMap,
    nested: {'Items': BaseItemDto.jsonShape},
  );
}
