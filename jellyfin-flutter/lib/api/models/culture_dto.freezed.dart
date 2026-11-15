// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'culture_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CultureDto {

 String get displayName;@JsonKey(name: 'ThreeLetterISOLanguageName') String? get threeLetterIsoLanguageName;
/// Create a copy of CultureDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CultureDtoCopyWith<CultureDto> get copyWith => _$CultureDtoCopyWithImpl<CultureDto>(this as CultureDto, _$identity);

  /// Serializes this CultureDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CultureDto&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.threeLetterIsoLanguageName, threeLetterIsoLanguageName) || other.threeLetterIsoLanguageName == threeLetterIsoLanguageName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,threeLetterIsoLanguageName);

@override
String toString() {
  return 'CultureDto(displayName: $displayName, threeLetterIsoLanguageName: $threeLetterIsoLanguageName)';
}


}

/// @nodoc
abstract mixin class $CultureDtoCopyWith<$Res>  {
  factory $CultureDtoCopyWith(CultureDto value, $Res Function(CultureDto) _then) = _$CultureDtoCopyWithImpl;
@useResult
$Res call({
 String displayName,@JsonKey(name: 'ThreeLetterISOLanguageName') String? threeLetterIsoLanguageName
});




}
/// @nodoc
class _$CultureDtoCopyWithImpl<$Res>
    implements $CultureDtoCopyWith<$Res> {
  _$CultureDtoCopyWithImpl(this._self, this._then);

  final CultureDto _self;
  final $Res Function(CultureDto) _then;

/// Create a copy of CultureDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? displayName = null,Object? threeLetterIsoLanguageName = freezed,}) {
  return _then(_self.copyWith(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,threeLetterIsoLanguageName: freezed == threeLetterIsoLanguageName ? _self.threeLetterIsoLanguageName : threeLetterIsoLanguageName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CultureDto].
extension CultureDtoPatterns on CultureDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CultureDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CultureDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CultureDto value)  $default,){
final _that = this;
switch (_that) {
case _CultureDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CultureDto value)?  $default,){
final _that = this;
switch (_that) {
case _CultureDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String displayName, @JsonKey(name: 'ThreeLetterISOLanguageName')  String? threeLetterIsoLanguageName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CultureDto() when $default != null:
return $default(_that.displayName,_that.threeLetterIsoLanguageName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String displayName, @JsonKey(name: 'ThreeLetterISOLanguageName')  String? threeLetterIsoLanguageName)  $default,) {final _that = this;
switch (_that) {
case _CultureDto():
return $default(_that.displayName,_that.threeLetterIsoLanguageName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String displayName, @JsonKey(name: 'ThreeLetterISOLanguageName')  String? threeLetterIsoLanguageName)?  $default,) {final _that = this;
switch (_that) {
case _CultureDto() when $default != null:
return $default(_that.displayName,_that.threeLetterIsoLanguageName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CultureDto implements CultureDto {
  const _CultureDto({required this.displayName, @JsonKey(name: 'ThreeLetterISOLanguageName') this.threeLetterIsoLanguageName});
  factory _CultureDto.fromJson(Map<String, dynamic> json) => _$CultureDtoFromJson(json);

@override final  String displayName;
@override@JsonKey(name: 'ThreeLetterISOLanguageName') final  String? threeLetterIsoLanguageName;

/// Create a copy of CultureDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CultureDtoCopyWith<_CultureDto> get copyWith => __$CultureDtoCopyWithImpl<_CultureDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CultureDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CultureDto&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.threeLetterIsoLanguageName, threeLetterIsoLanguageName) || other.threeLetterIsoLanguageName == threeLetterIsoLanguageName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,displayName,threeLetterIsoLanguageName);

@override
String toString() {
  return 'CultureDto(displayName: $displayName, threeLetterIsoLanguageName: $threeLetterIsoLanguageName)';
}


}

/// @nodoc
abstract mixin class _$CultureDtoCopyWith<$Res> implements $CultureDtoCopyWith<$Res> {
  factory _$CultureDtoCopyWith(_CultureDto value, $Res Function(_CultureDto) _then) = __$CultureDtoCopyWithImpl;
@override @useResult
$Res call({
 String displayName,@JsonKey(name: 'ThreeLetterISOLanguageName') String? threeLetterIsoLanguageName
});




}
/// @nodoc
class __$CultureDtoCopyWithImpl<$Res>
    implements _$CultureDtoCopyWith<$Res> {
  __$CultureDtoCopyWithImpl(this._self, this._then);

  final _CultureDto _self;
  final $Res Function(_CultureDto) _then;

/// Create a copy of CultureDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? displayName = null,Object? threeLetterIsoLanguageName = freezed,}) {
  return _then(_CultureDto(
displayName: null == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String,threeLetterIsoLanguageName: freezed == threeLetterIsoLanguageName ? _self.threeLetterIsoLanguageName : threeLetterIsoLanguageName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
