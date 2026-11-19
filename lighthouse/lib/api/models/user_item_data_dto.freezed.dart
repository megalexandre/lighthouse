// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_item_data_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserItemDataDto {

 int get playbackPositionTicks; bool get played;/// 0–100; only present while partly watched.
 double? get playedPercentage;/// For series and seasons.
 int? get unplayedItemCount;
/// Create a copy of UserItemDataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserItemDataDtoCopyWith<UserItemDataDto> get copyWith => _$UserItemDataDtoCopyWithImpl<UserItemDataDto>(this as UserItemDataDto, _$identity);

  /// Serializes this UserItemDataDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserItemDataDto&&(identical(other.playbackPositionTicks, playbackPositionTicks) || other.playbackPositionTicks == playbackPositionTicks)&&(identical(other.played, played) || other.played == played)&&(identical(other.playedPercentage, playedPercentage) || other.playedPercentage == playedPercentage)&&(identical(other.unplayedItemCount, unplayedItemCount) || other.unplayedItemCount == unplayedItemCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playbackPositionTicks,played,playedPercentage,unplayedItemCount);

@override
String toString() {
  return 'UserItemDataDto(playbackPositionTicks: $playbackPositionTicks, played: $played, playedPercentage: $playedPercentage, unplayedItemCount: $unplayedItemCount)';
}


}

/// @nodoc
abstract mixin class $UserItemDataDtoCopyWith<$Res>  {
  factory $UserItemDataDtoCopyWith(UserItemDataDto value, $Res Function(UserItemDataDto) _then) = _$UserItemDataDtoCopyWithImpl;
@useResult
$Res call({
 int playbackPositionTicks, bool played, double? playedPercentage, int? unplayedItemCount
});




}
/// @nodoc
class _$UserItemDataDtoCopyWithImpl<$Res>
    implements $UserItemDataDtoCopyWith<$Res> {
  _$UserItemDataDtoCopyWithImpl(this._self, this._then);

  final UserItemDataDto _self;
  final $Res Function(UserItemDataDto) _then;

/// Create a copy of UserItemDataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playbackPositionTicks = null,Object? played = null,Object? playedPercentage = freezed,Object? unplayedItemCount = freezed,}) {
  return _then(_self.copyWith(
playbackPositionTicks: null == playbackPositionTicks ? _self.playbackPositionTicks : playbackPositionTicks // ignore: cast_nullable_to_non_nullable
as int,played: null == played ? _self.played : played // ignore: cast_nullable_to_non_nullable
as bool,playedPercentage: freezed == playedPercentage ? _self.playedPercentage : playedPercentage // ignore: cast_nullable_to_non_nullable
as double?,unplayedItemCount: freezed == unplayedItemCount ? _self.unplayedItemCount : unplayedItemCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [UserItemDataDto].
extension UserItemDataDtoPatterns on UserItemDataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserItemDataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserItemDataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserItemDataDto value)  $default,){
final _that = this;
switch (_that) {
case _UserItemDataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserItemDataDto value)?  $default,){
final _that = this;
switch (_that) {
case _UserItemDataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int playbackPositionTicks,  bool played,  double? playedPercentage,  int? unplayedItemCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserItemDataDto() when $default != null:
return $default(_that.playbackPositionTicks,_that.played,_that.playedPercentage,_that.unplayedItemCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int playbackPositionTicks,  bool played,  double? playedPercentage,  int? unplayedItemCount)  $default,) {final _that = this;
switch (_that) {
case _UserItemDataDto():
return $default(_that.playbackPositionTicks,_that.played,_that.playedPercentage,_that.unplayedItemCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int playbackPositionTicks,  bool played,  double? playedPercentage,  int? unplayedItemCount)?  $default,) {final _that = this;
switch (_that) {
case _UserItemDataDto() when $default != null:
return $default(_that.playbackPositionTicks,_that.played,_that.playedPercentage,_that.unplayedItemCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserItemDataDto implements UserItemDataDto {
  const _UserItemDataDto({this.playbackPositionTicks = 0, this.played = false, this.playedPercentage, this.unplayedItemCount});
  factory _UserItemDataDto.fromJson(Map<String, dynamic> json) => _$UserItemDataDtoFromJson(json);

@override@JsonKey() final  int playbackPositionTicks;
@override@JsonKey() final  bool played;
/// 0–100; only present while partly watched.
@override final  double? playedPercentage;
/// For series and seasons.
@override final  int? unplayedItemCount;

/// Create a copy of UserItemDataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserItemDataDtoCopyWith<_UserItemDataDto> get copyWith => __$UserItemDataDtoCopyWithImpl<_UserItemDataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserItemDataDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserItemDataDto&&(identical(other.playbackPositionTicks, playbackPositionTicks) || other.playbackPositionTicks == playbackPositionTicks)&&(identical(other.played, played) || other.played == played)&&(identical(other.playedPercentage, playedPercentage) || other.playedPercentage == playedPercentage)&&(identical(other.unplayedItemCount, unplayedItemCount) || other.unplayedItemCount == unplayedItemCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playbackPositionTicks,played,playedPercentage,unplayedItemCount);

@override
String toString() {
  return 'UserItemDataDto(playbackPositionTicks: $playbackPositionTicks, played: $played, playedPercentage: $playedPercentage, unplayedItemCount: $unplayedItemCount)';
}


}

/// @nodoc
abstract mixin class _$UserItemDataDtoCopyWith<$Res> implements $UserItemDataDtoCopyWith<$Res> {
  factory _$UserItemDataDtoCopyWith(_UserItemDataDto value, $Res Function(_UserItemDataDto) _then) = __$UserItemDataDtoCopyWithImpl;
@override @useResult
$Res call({
 int playbackPositionTicks, bool played, double? playedPercentage, int? unplayedItemCount
});




}
/// @nodoc
class __$UserItemDataDtoCopyWithImpl<$Res>
    implements _$UserItemDataDtoCopyWith<$Res> {
  __$UserItemDataDtoCopyWithImpl(this._self, this._then);

  final _UserItemDataDto _self;
  final $Res Function(_UserItemDataDto) _then;

/// Create a copy of UserItemDataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playbackPositionTicks = null,Object? played = null,Object? playedPercentage = freezed,Object? unplayedItemCount = freezed,}) {
  return _then(_UserItemDataDto(
playbackPositionTicks: null == playbackPositionTicks ? _self.playbackPositionTicks : playbackPositionTicks // ignore: cast_nullable_to_non_nullable
as int,played: null == played ? _self.played : played // ignore: cast_nullable_to_non_nullable
as bool,playedPercentage: freezed == playedPercentage ? _self.playedPercentage : playedPercentage // ignore: cast_nullable_to_non_nullable
as double?,unplayedItemCount: freezed == unplayedItemCount ? _self.unplayedItemCount : unplayedItemCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
