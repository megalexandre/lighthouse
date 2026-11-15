// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_item_dto_query_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BaseItemDtoQueryResult {

 List<BaseItemDto> get items; int get totalRecordCount; int get startIndex;
/// Create a copy of BaseItemDtoQueryResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaseItemDtoQueryResultCopyWith<BaseItemDtoQueryResult> get copyWith => _$BaseItemDtoQueryResultCopyWithImpl<BaseItemDtoQueryResult>(this as BaseItemDtoQueryResult, _$identity);

  /// Serializes this BaseItemDtoQueryResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaseItemDtoQueryResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalRecordCount, totalRecordCount) || other.totalRecordCount == totalRecordCount)&&(identical(other.startIndex, startIndex) || other.startIndex == startIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalRecordCount,startIndex);

@override
String toString() {
  return 'BaseItemDtoQueryResult(items: $items, totalRecordCount: $totalRecordCount, startIndex: $startIndex)';
}


}

/// @nodoc
abstract mixin class $BaseItemDtoQueryResultCopyWith<$Res>  {
  factory $BaseItemDtoQueryResultCopyWith(BaseItemDtoQueryResult value, $Res Function(BaseItemDtoQueryResult) _then) = _$BaseItemDtoQueryResultCopyWithImpl;
@useResult
$Res call({
 List<BaseItemDto> items, int totalRecordCount, int startIndex
});




}
/// @nodoc
class _$BaseItemDtoQueryResultCopyWithImpl<$Res>
    implements $BaseItemDtoQueryResultCopyWith<$Res> {
  _$BaseItemDtoQueryResultCopyWithImpl(this._self, this._then);

  final BaseItemDtoQueryResult _self;
  final $Res Function(BaseItemDtoQueryResult) _then;

/// Create a copy of BaseItemDtoQueryResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? items = null,Object? totalRecordCount = null,Object? startIndex = null,}) {
  return _then(_self.copyWith(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BaseItemDto>,totalRecordCount: null == totalRecordCount ? _self.totalRecordCount : totalRecordCount // ignore: cast_nullable_to_non_nullable
as int,startIndex: null == startIndex ? _self.startIndex : startIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BaseItemDtoQueryResult].
extension BaseItemDtoQueryResultPatterns on BaseItemDtoQueryResult {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BaseItemDtoQueryResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BaseItemDtoQueryResult() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BaseItemDtoQueryResult value)  $default,){
final _that = this;
switch (_that) {
case _BaseItemDtoQueryResult():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BaseItemDtoQueryResult value)?  $default,){
final _that = this;
switch (_that) {
case _BaseItemDtoQueryResult() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<BaseItemDto> items,  int totalRecordCount,  int startIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BaseItemDtoQueryResult() when $default != null:
return $default(_that.items,_that.totalRecordCount,_that.startIndex);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<BaseItemDto> items,  int totalRecordCount,  int startIndex)  $default,) {final _that = this;
switch (_that) {
case _BaseItemDtoQueryResult():
return $default(_that.items,_that.totalRecordCount,_that.startIndex);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<BaseItemDto> items,  int totalRecordCount,  int startIndex)?  $default,) {final _that = this;
switch (_that) {
case _BaseItemDtoQueryResult() when $default != null:
return $default(_that.items,_that.totalRecordCount,_that.startIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BaseItemDtoQueryResult implements BaseItemDtoQueryResult {
  const _BaseItemDtoQueryResult({this.items = const [], this.totalRecordCount = 0, this.startIndex = 0});
  factory _BaseItemDtoQueryResult.fromJson(Map<String, dynamic> json) => _$BaseItemDtoQueryResultFromJson(json);

@override@JsonKey() final  List<BaseItemDto> items;
@override@JsonKey() final  int totalRecordCount;
@override@JsonKey() final  int startIndex;

/// Create a copy of BaseItemDtoQueryResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaseItemDtoQueryResultCopyWith<_BaseItemDtoQueryResult> get copyWith => __$BaseItemDtoQueryResultCopyWithImpl<_BaseItemDtoQueryResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BaseItemDtoQueryResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BaseItemDtoQueryResult&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.totalRecordCount, totalRecordCount) || other.totalRecordCount == totalRecordCount)&&(identical(other.startIndex, startIndex) || other.startIndex == startIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(items),totalRecordCount,startIndex);

@override
String toString() {
  return 'BaseItemDtoQueryResult(items: $items, totalRecordCount: $totalRecordCount, startIndex: $startIndex)';
}


}

/// @nodoc
abstract mixin class _$BaseItemDtoQueryResultCopyWith<$Res> implements $BaseItemDtoQueryResultCopyWith<$Res> {
  factory _$BaseItemDtoQueryResultCopyWith(_BaseItemDtoQueryResult value, $Res Function(_BaseItemDtoQueryResult) _then) = __$BaseItemDtoQueryResultCopyWithImpl;
@override @useResult
$Res call({
 List<BaseItemDto> items, int totalRecordCount, int startIndex
});




}
/// @nodoc
class __$BaseItemDtoQueryResultCopyWithImpl<$Res>
    implements _$BaseItemDtoQueryResultCopyWith<$Res> {
  __$BaseItemDtoQueryResultCopyWithImpl(this._self, this._then);

  final _BaseItemDtoQueryResult _self;
  final $Res Function(_BaseItemDtoQueryResult) _then;

/// Create a copy of BaseItemDtoQueryResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? items = null,Object? totalRecordCount = null,Object? startIndex = null,}) {
  return _then(_BaseItemDtoQueryResult(
items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<BaseItemDto>,totalRecordCount: null == totalRecordCount ? _self.totalRecordCount : totalRecordCount // ignore: cast_nullable_to_non_nullable
as int,startIndex: null == startIndex ? _self.startIndex : startIndex // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
