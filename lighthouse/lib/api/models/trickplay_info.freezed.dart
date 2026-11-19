// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trickplay_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrickplayInfo {

 int get width; int get height; int get tileWidth; int get tileHeight; int get thumbnailCount; int get interval;
/// Create a copy of TrickplayInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrickplayInfoCopyWith<TrickplayInfo> get copyWith => _$TrickplayInfoCopyWithImpl<TrickplayInfo>(this as TrickplayInfo, _$identity);

  /// Serializes this TrickplayInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrickplayInfo&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.tileWidth, tileWidth) || other.tileWidth == tileWidth)&&(identical(other.tileHeight, tileHeight) || other.tileHeight == tileHeight)&&(identical(other.thumbnailCount, thumbnailCount) || other.thumbnailCount == thumbnailCount)&&(identical(other.interval, interval) || other.interval == interval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height,tileWidth,tileHeight,thumbnailCount,interval);

@override
String toString() {
  return 'TrickplayInfo(width: $width, height: $height, tileWidth: $tileWidth, tileHeight: $tileHeight, thumbnailCount: $thumbnailCount, interval: $interval)';
}


}

/// @nodoc
abstract mixin class $TrickplayInfoCopyWith<$Res>  {
  factory $TrickplayInfoCopyWith(TrickplayInfo value, $Res Function(TrickplayInfo) _then) = _$TrickplayInfoCopyWithImpl;
@useResult
$Res call({
 int width, int height, int tileWidth, int tileHeight, int thumbnailCount, int interval
});




}
/// @nodoc
class _$TrickplayInfoCopyWithImpl<$Res>
    implements $TrickplayInfoCopyWith<$Res> {
  _$TrickplayInfoCopyWithImpl(this._self, this._then);

  final TrickplayInfo _self;
  final $Res Function(TrickplayInfo) _then;

/// Create a copy of TrickplayInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? width = null,Object? height = null,Object? tileWidth = null,Object? tileHeight = null,Object? thumbnailCount = null,Object? interval = null,}) {
  return _then(_self.copyWith(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,tileWidth: null == tileWidth ? _self.tileWidth : tileWidth // ignore: cast_nullable_to_non_nullable
as int,tileHeight: null == tileHeight ? _self.tileHeight : tileHeight // ignore: cast_nullable_to_non_nullable
as int,thumbnailCount: null == thumbnailCount ? _self.thumbnailCount : thumbnailCount // ignore: cast_nullable_to_non_nullable
as int,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrickplayInfo].
extension TrickplayInfoPatterns on TrickplayInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrickplayInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrickplayInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrickplayInfo value)  $default,){
final _that = this;
switch (_that) {
case _TrickplayInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrickplayInfo value)?  $default,){
final _that = this;
switch (_that) {
case _TrickplayInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int width,  int height,  int tileWidth,  int tileHeight,  int thumbnailCount,  int interval)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrickplayInfo() when $default != null:
return $default(_that.width,_that.height,_that.tileWidth,_that.tileHeight,_that.thumbnailCount,_that.interval);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int width,  int height,  int tileWidth,  int tileHeight,  int thumbnailCount,  int interval)  $default,) {final _that = this;
switch (_that) {
case _TrickplayInfo():
return $default(_that.width,_that.height,_that.tileWidth,_that.tileHeight,_that.thumbnailCount,_that.interval);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int width,  int height,  int tileWidth,  int tileHeight,  int thumbnailCount,  int interval)?  $default,) {final _that = this;
switch (_that) {
case _TrickplayInfo() when $default != null:
return $default(_that.width,_that.height,_that.tileWidth,_that.tileHeight,_that.thumbnailCount,_that.interval);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrickplayInfo extends TrickplayInfo {
  const _TrickplayInfo({required this.width, required this.height, required this.tileWidth, required this.tileHeight, required this.thumbnailCount, required this.interval}): super._();
  factory _TrickplayInfo.fromJson(Map<String, dynamic> json) => _$TrickplayInfoFromJson(json);

@override final  int width;
@override final  int height;
@override final  int tileWidth;
@override final  int tileHeight;
@override final  int thumbnailCount;
@override final  int interval;

/// Create a copy of TrickplayInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrickplayInfoCopyWith<_TrickplayInfo> get copyWith => __$TrickplayInfoCopyWithImpl<_TrickplayInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrickplayInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrickplayInfo&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.tileWidth, tileWidth) || other.tileWidth == tileWidth)&&(identical(other.tileHeight, tileHeight) || other.tileHeight == tileHeight)&&(identical(other.thumbnailCount, thumbnailCount) || other.thumbnailCount == thumbnailCount)&&(identical(other.interval, interval) || other.interval == interval));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,width,height,tileWidth,tileHeight,thumbnailCount,interval);

@override
String toString() {
  return 'TrickplayInfo(width: $width, height: $height, tileWidth: $tileWidth, tileHeight: $tileHeight, thumbnailCount: $thumbnailCount, interval: $interval)';
}


}

/// @nodoc
abstract mixin class _$TrickplayInfoCopyWith<$Res> implements $TrickplayInfoCopyWith<$Res> {
  factory _$TrickplayInfoCopyWith(_TrickplayInfo value, $Res Function(_TrickplayInfo) _then) = __$TrickplayInfoCopyWithImpl;
@override @useResult
$Res call({
 int width, int height, int tileWidth, int tileHeight, int thumbnailCount, int interval
});




}
/// @nodoc
class __$TrickplayInfoCopyWithImpl<$Res>
    implements _$TrickplayInfoCopyWith<$Res> {
  __$TrickplayInfoCopyWithImpl(this._self, this._then);

  final _TrickplayInfo _self;
  final $Res Function(_TrickplayInfo) _then;

/// Create a copy of TrickplayInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? width = null,Object? height = null,Object? tileWidth = null,Object? tileHeight = null,Object? thumbnailCount = null,Object? interval = null,}) {
  return _then(_TrickplayInfo(
width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,tileWidth: null == tileWidth ? _self.tileWidth : tileWidth // ignore: cast_nullable_to_non_nullable
as int,tileHeight: null == tileHeight ? _self.tileHeight : tileHeight // ignore: cast_nullable_to_non_nullable
as int,thumbnailCount: null == thumbnailCount ? _self.thumbnailCount : thumbnailCount // ignore: cast_nullable_to_non_nullable
as int,interval: null == interval ? _self.interval : interval // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
