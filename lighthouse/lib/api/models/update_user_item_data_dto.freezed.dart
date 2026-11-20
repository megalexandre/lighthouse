// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'update_user_item_data_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$UpdateUserItemDataDto {

 int? get playbackPositionTicks; bool? get played;
/// Create a copy of UpdateUserItemDataDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateUserItemDataDtoCopyWith<UpdateUserItemDataDto> get copyWith => _$UpdateUserItemDataDtoCopyWithImpl<UpdateUserItemDataDto>(this as UpdateUserItemDataDto, _$identity);

  /// Serializes this UpdateUserItemDataDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateUserItemDataDto&&(identical(other.playbackPositionTicks, playbackPositionTicks) || other.playbackPositionTicks == playbackPositionTicks)&&(identical(other.played, played) || other.played == played));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playbackPositionTicks,played);

@override
String toString() {
  return 'UpdateUserItemDataDto(playbackPositionTicks: $playbackPositionTicks, played: $played)';
}


}

/// @nodoc
abstract mixin class $UpdateUserItemDataDtoCopyWith<$Res>  {
  factory $UpdateUserItemDataDtoCopyWith(UpdateUserItemDataDto value, $Res Function(UpdateUserItemDataDto) _then) = _$UpdateUserItemDataDtoCopyWithImpl;
@useResult
$Res call({
 int? playbackPositionTicks, bool? played
});




}
/// @nodoc
class _$UpdateUserItemDataDtoCopyWithImpl<$Res>
    implements $UpdateUserItemDataDtoCopyWith<$Res> {
  _$UpdateUserItemDataDtoCopyWithImpl(this._self, this._then);

  final UpdateUserItemDataDto _self;
  final $Res Function(UpdateUserItemDataDto) _then;

/// Create a copy of UpdateUserItemDataDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? playbackPositionTicks = freezed,Object? played = freezed,}) {
  return _then(_self.copyWith(
playbackPositionTicks: freezed == playbackPositionTicks ? _self.playbackPositionTicks : playbackPositionTicks // ignore: cast_nullable_to_non_nullable
as int?,played: freezed == played ? _self.played : played // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateUserItemDataDto].
extension UpdateUserItemDataDtoPatterns on UpdateUserItemDataDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateUserItemDataDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateUserItemDataDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateUserItemDataDto value)  $default,){
final _that = this;
switch (_that) {
case _UpdateUserItemDataDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateUserItemDataDto value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateUserItemDataDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int? playbackPositionTicks,  bool? played)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateUserItemDataDto() when $default != null:
return $default(_that.playbackPositionTicks,_that.played);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int? playbackPositionTicks,  bool? played)  $default,) {final _that = this;
switch (_that) {
case _UpdateUserItemDataDto():
return $default(_that.playbackPositionTicks,_that.played);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int? playbackPositionTicks,  bool? played)?  $default,) {final _that = this;
switch (_that) {
case _UpdateUserItemDataDto() when $default != null:
return $default(_that.playbackPositionTicks,_that.played);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _UpdateUserItemDataDto implements UpdateUserItemDataDto {
  const _UpdateUserItemDataDto({this.playbackPositionTicks, this.played});
  

@override final  int? playbackPositionTicks;
@override final  bool? played;

/// Create a copy of UpdateUserItemDataDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateUserItemDataDtoCopyWith<_UpdateUserItemDataDto> get copyWith => __$UpdateUserItemDataDtoCopyWithImpl<_UpdateUserItemDataDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateUserItemDataDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateUserItemDataDto&&(identical(other.playbackPositionTicks, playbackPositionTicks) || other.playbackPositionTicks == playbackPositionTicks)&&(identical(other.played, played) || other.played == played));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,playbackPositionTicks,played);

@override
String toString() {
  return 'UpdateUserItemDataDto(playbackPositionTicks: $playbackPositionTicks, played: $played)';
}


}

/// @nodoc
abstract mixin class _$UpdateUserItemDataDtoCopyWith<$Res> implements $UpdateUserItemDataDtoCopyWith<$Res> {
  factory _$UpdateUserItemDataDtoCopyWith(_UpdateUserItemDataDto value, $Res Function(_UpdateUserItemDataDto) _then) = __$UpdateUserItemDataDtoCopyWithImpl;
@override @useResult
$Res call({
 int? playbackPositionTicks, bool? played
});




}
/// @nodoc
class __$UpdateUserItemDataDtoCopyWithImpl<$Res>
    implements _$UpdateUserItemDataDtoCopyWith<$Res> {
  __$UpdateUserItemDataDtoCopyWithImpl(this._self, this._then);

  final _UpdateUserItemDataDto _self;
  final $Res Function(_UpdateUserItemDataDto) _then;

/// Create a copy of UpdateUserItemDataDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? playbackPositionTicks = freezed,Object? played = freezed,}) {
  return _then(_UpdateUserItemDataDto(
playbackPositionTicks: freezed == playbackPositionTicks ? _self.playbackPositionTicks : playbackPositionTicks // ignore: cast_nullable_to_non_nullable
as int?,played: freezed == played ? _self.played : played // ignore: cast_nullable_to_non_nullable
as bool?,
  ));
}


}

// dart format on
