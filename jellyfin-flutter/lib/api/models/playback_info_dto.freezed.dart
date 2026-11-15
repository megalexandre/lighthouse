// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_info_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PlaybackInfoDto {

 String get userId; DeviceProfile get deviceProfile; int? get startTimeTicks; int? get audioStreamIndex; int? get subtitleStreamIndex; String? get mediaSourceId; int? get maxStreamingBitrate; bool get autoOpenLiveStream;
/// Create a copy of PlaybackInfoDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackInfoDtoCopyWith<PlaybackInfoDto> get copyWith => _$PlaybackInfoDtoCopyWithImpl<PlaybackInfoDto>(this as PlaybackInfoDto, _$identity);

  /// Serializes this PlaybackInfoDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackInfoDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.deviceProfile, deviceProfile) || other.deviceProfile == deviceProfile)&&(identical(other.startTimeTicks, startTimeTicks) || other.startTimeTicks == startTimeTicks)&&(identical(other.audioStreamIndex, audioStreamIndex) || other.audioStreamIndex == audioStreamIndex)&&(identical(other.subtitleStreamIndex, subtitleStreamIndex) || other.subtitleStreamIndex == subtitleStreamIndex)&&(identical(other.mediaSourceId, mediaSourceId) || other.mediaSourceId == mediaSourceId)&&(identical(other.maxStreamingBitrate, maxStreamingBitrate) || other.maxStreamingBitrate == maxStreamingBitrate)&&(identical(other.autoOpenLiveStream, autoOpenLiveStream) || other.autoOpenLiveStream == autoOpenLiveStream));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,deviceProfile,startTimeTicks,audioStreamIndex,subtitleStreamIndex,mediaSourceId,maxStreamingBitrate,autoOpenLiveStream);

@override
String toString() {
  return 'PlaybackInfoDto(userId: $userId, deviceProfile: $deviceProfile, startTimeTicks: $startTimeTicks, audioStreamIndex: $audioStreamIndex, subtitleStreamIndex: $subtitleStreamIndex, mediaSourceId: $mediaSourceId, maxStreamingBitrate: $maxStreamingBitrate, autoOpenLiveStream: $autoOpenLiveStream)';
}


}

/// @nodoc
abstract mixin class $PlaybackInfoDtoCopyWith<$Res>  {
  factory $PlaybackInfoDtoCopyWith(PlaybackInfoDto value, $Res Function(PlaybackInfoDto) _then) = _$PlaybackInfoDtoCopyWithImpl;
@useResult
$Res call({
 String userId, DeviceProfile deviceProfile, int? startTimeTicks, int? audioStreamIndex, int? subtitleStreamIndex, String? mediaSourceId, int? maxStreamingBitrate, bool autoOpenLiveStream
});


$DeviceProfileCopyWith<$Res> get deviceProfile;

}
/// @nodoc
class _$PlaybackInfoDtoCopyWithImpl<$Res>
    implements $PlaybackInfoDtoCopyWith<$Res> {
  _$PlaybackInfoDtoCopyWithImpl(this._self, this._then);

  final PlaybackInfoDto _self;
  final $Res Function(PlaybackInfoDto) _then;

/// Create a copy of PlaybackInfoDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? deviceProfile = null,Object? startTimeTicks = freezed,Object? audioStreamIndex = freezed,Object? subtitleStreamIndex = freezed,Object? mediaSourceId = freezed,Object? maxStreamingBitrate = freezed,Object? autoOpenLiveStream = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,deviceProfile: null == deviceProfile ? _self.deviceProfile : deviceProfile // ignore: cast_nullable_to_non_nullable
as DeviceProfile,startTimeTicks: freezed == startTimeTicks ? _self.startTimeTicks : startTimeTicks // ignore: cast_nullable_to_non_nullable
as int?,audioStreamIndex: freezed == audioStreamIndex ? _self.audioStreamIndex : audioStreamIndex // ignore: cast_nullable_to_non_nullable
as int?,subtitleStreamIndex: freezed == subtitleStreamIndex ? _self.subtitleStreamIndex : subtitleStreamIndex // ignore: cast_nullable_to_non_nullable
as int?,mediaSourceId: freezed == mediaSourceId ? _self.mediaSourceId : mediaSourceId // ignore: cast_nullable_to_non_nullable
as String?,maxStreamingBitrate: freezed == maxStreamingBitrate ? _self.maxStreamingBitrate : maxStreamingBitrate // ignore: cast_nullable_to_non_nullable
as int?,autoOpenLiveStream: null == autoOpenLiveStream ? _self.autoOpenLiveStream : autoOpenLiveStream // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of PlaybackInfoDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceProfileCopyWith<$Res> get deviceProfile {
  
  return $DeviceProfileCopyWith<$Res>(_self.deviceProfile, (value) {
    return _then(_self.copyWith(deviceProfile: value));
  });
}
}


/// Adds pattern-matching-related methods to [PlaybackInfoDto].
extension PlaybackInfoDtoPatterns on PlaybackInfoDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackInfoDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackInfoDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackInfoDto value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackInfoDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackInfoDto value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackInfoDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  DeviceProfile deviceProfile,  int? startTimeTicks,  int? audioStreamIndex,  int? subtitleStreamIndex,  String? mediaSourceId,  int? maxStreamingBitrate,  bool autoOpenLiveStream)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackInfoDto() when $default != null:
return $default(_that.userId,_that.deviceProfile,_that.startTimeTicks,_that.audioStreamIndex,_that.subtitleStreamIndex,_that.mediaSourceId,_that.maxStreamingBitrate,_that.autoOpenLiveStream);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  DeviceProfile deviceProfile,  int? startTimeTicks,  int? audioStreamIndex,  int? subtitleStreamIndex,  String? mediaSourceId,  int? maxStreamingBitrate,  bool autoOpenLiveStream)  $default,) {final _that = this;
switch (_that) {
case _PlaybackInfoDto():
return $default(_that.userId,_that.deviceProfile,_that.startTimeTicks,_that.audioStreamIndex,_that.subtitleStreamIndex,_that.mediaSourceId,_that.maxStreamingBitrate,_that.autoOpenLiveStream);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  DeviceProfile deviceProfile,  int? startTimeTicks,  int? audioStreamIndex,  int? subtitleStreamIndex,  String? mediaSourceId,  int? maxStreamingBitrate,  bool autoOpenLiveStream)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackInfoDto() when $default != null:
return $default(_that.userId,_that.deviceProfile,_that.startTimeTicks,_that.audioStreamIndex,_that.subtitleStreamIndex,_that.mediaSourceId,_that.maxStreamingBitrate,_that.autoOpenLiveStream);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PlaybackInfoDto implements PlaybackInfoDto {
  const _PlaybackInfoDto({required this.userId, required this.deviceProfile, this.startTimeTicks, this.audioStreamIndex, this.subtitleStreamIndex, this.mediaSourceId, this.maxStreamingBitrate, this.autoOpenLiveStream = true});
  factory _PlaybackInfoDto.fromJson(Map<String, dynamic> json) => _$PlaybackInfoDtoFromJson(json);

@override final  String userId;
@override final  DeviceProfile deviceProfile;
@override final  int? startTimeTicks;
@override final  int? audioStreamIndex;
@override final  int? subtitleStreamIndex;
@override final  String? mediaSourceId;
@override final  int? maxStreamingBitrate;
@override@JsonKey() final  bool autoOpenLiveStream;

/// Create a copy of PlaybackInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackInfoDtoCopyWith<_PlaybackInfoDto> get copyWith => __$PlaybackInfoDtoCopyWithImpl<_PlaybackInfoDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaybackInfoDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackInfoDto&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.deviceProfile, deviceProfile) || other.deviceProfile == deviceProfile)&&(identical(other.startTimeTicks, startTimeTicks) || other.startTimeTicks == startTimeTicks)&&(identical(other.audioStreamIndex, audioStreamIndex) || other.audioStreamIndex == audioStreamIndex)&&(identical(other.subtitleStreamIndex, subtitleStreamIndex) || other.subtitleStreamIndex == subtitleStreamIndex)&&(identical(other.mediaSourceId, mediaSourceId) || other.mediaSourceId == mediaSourceId)&&(identical(other.maxStreamingBitrate, maxStreamingBitrate) || other.maxStreamingBitrate == maxStreamingBitrate)&&(identical(other.autoOpenLiveStream, autoOpenLiveStream) || other.autoOpenLiveStream == autoOpenLiveStream));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,deviceProfile,startTimeTicks,audioStreamIndex,subtitleStreamIndex,mediaSourceId,maxStreamingBitrate,autoOpenLiveStream);

@override
String toString() {
  return 'PlaybackInfoDto(userId: $userId, deviceProfile: $deviceProfile, startTimeTicks: $startTimeTicks, audioStreamIndex: $audioStreamIndex, subtitleStreamIndex: $subtitleStreamIndex, mediaSourceId: $mediaSourceId, maxStreamingBitrate: $maxStreamingBitrate, autoOpenLiveStream: $autoOpenLiveStream)';
}


}

/// @nodoc
abstract mixin class _$PlaybackInfoDtoCopyWith<$Res> implements $PlaybackInfoDtoCopyWith<$Res> {
  factory _$PlaybackInfoDtoCopyWith(_PlaybackInfoDto value, $Res Function(_PlaybackInfoDto) _then) = __$PlaybackInfoDtoCopyWithImpl;
@override @useResult
$Res call({
 String userId, DeviceProfile deviceProfile, int? startTimeTicks, int? audioStreamIndex, int? subtitleStreamIndex, String? mediaSourceId, int? maxStreamingBitrate, bool autoOpenLiveStream
});


@override $DeviceProfileCopyWith<$Res> get deviceProfile;

}
/// @nodoc
class __$PlaybackInfoDtoCopyWithImpl<$Res>
    implements _$PlaybackInfoDtoCopyWith<$Res> {
  __$PlaybackInfoDtoCopyWithImpl(this._self, this._then);

  final _PlaybackInfoDto _self;
  final $Res Function(_PlaybackInfoDto) _then;

/// Create a copy of PlaybackInfoDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? deviceProfile = null,Object? startTimeTicks = freezed,Object? audioStreamIndex = freezed,Object? subtitleStreamIndex = freezed,Object? mediaSourceId = freezed,Object? maxStreamingBitrate = freezed,Object? autoOpenLiveStream = null,}) {
  return _then(_PlaybackInfoDto(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,deviceProfile: null == deviceProfile ? _self.deviceProfile : deviceProfile // ignore: cast_nullable_to_non_nullable
as DeviceProfile,startTimeTicks: freezed == startTimeTicks ? _self.startTimeTicks : startTimeTicks // ignore: cast_nullable_to_non_nullable
as int?,audioStreamIndex: freezed == audioStreamIndex ? _self.audioStreamIndex : audioStreamIndex // ignore: cast_nullable_to_non_nullable
as int?,subtitleStreamIndex: freezed == subtitleStreamIndex ? _self.subtitleStreamIndex : subtitleStreamIndex // ignore: cast_nullable_to_non_nullable
as int?,mediaSourceId: freezed == mediaSourceId ? _self.mediaSourceId : mediaSourceId // ignore: cast_nullable_to_non_nullable
as String?,maxStreamingBitrate: freezed == maxStreamingBitrate ? _self.maxStreamingBitrate : maxStreamingBitrate // ignore: cast_nullable_to_non_nullable
as int?,autoOpenLiveStream: null == autoOpenLiveStream ? _self.autoOpenLiveStream : autoOpenLiveStream // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of PlaybackInfoDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DeviceProfileCopyWith<$Res> get deviceProfile {
  
  return $DeviceProfileCopyWith<$Res>(_self.deviceProfile, (value) {
    return _then(_self.copyWith(deviceProfile: value));
  });
}
}

// dart format on
