// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_configuration.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserConfiguration {

/// ISO 639-2 code (e.g. "por"); null or empty = the file's default.
 String? get audioLanguagePreference; String? get subtitleLanguagePreference;@JsonKey(unknownEnumValue: SubtitlePlaybackMode.defaultMode) SubtitlePlaybackMode get subtitleMode; bool get playDefaultAudioTrack; bool get enableNextEpisodeAutoPlay;
/// Create a copy of UserConfiguration
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserConfigurationCopyWith<UserConfiguration> get copyWith => _$UserConfigurationCopyWithImpl<UserConfiguration>(this as UserConfiguration, _$identity);

  /// Serializes this UserConfiguration to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserConfiguration&&(identical(other.audioLanguagePreference, audioLanguagePreference) || other.audioLanguagePreference == audioLanguagePreference)&&(identical(other.subtitleLanguagePreference, subtitleLanguagePreference) || other.subtitleLanguagePreference == subtitleLanguagePreference)&&(identical(other.subtitleMode, subtitleMode) || other.subtitleMode == subtitleMode)&&(identical(other.playDefaultAudioTrack, playDefaultAudioTrack) || other.playDefaultAudioTrack == playDefaultAudioTrack)&&(identical(other.enableNextEpisodeAutoPlay, enableNextEpisodeAutoPlay) || other.enableNextEpisodeAutoPlay == enableNextEpisodeAutoPlay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,audioLanguagePreference,subtitleLanguagePreference,subtitleMode,playDefaultAudioTrack,enableNextEpisodeAutoPlay);

@override
String toString() {
  return 'UserConfiguration(audioLanguagePreference: $audioLanguagePreference, subtitleLanguagePreference: $subtitleLanguagePreference, subtitleMode: $subtitleMode, playDefaultAudioTrack: $playDefaultAudioTrack, enableNextEpisodeAutoPlay: $enableNextEpisodeAutoPlay)';
}


}

/// @nodoc
abstract mixin class $UserConfigurationCopyWith<$Res>  {
  factory $UserConfigurationCopyWith(UserConfiguration value, $Res Function(UserConfiguration) _then) = _$UserConfigurationCopyWithImpl;
@useResult
$Res call({
 String? audioLanguagePreference, String? subtitleLanguagePreference,@JsonKey(unknownEnumValue: SubtitlePlaybackMode.defaultMode) SubtitlePlaybackMode subtitleMode, bool playDefaultAudioTrack, bool enableNextEpisodeAutoPlay
});




}
/// @nodoc
class _$UserConfigurationCopyWithImpl<$Res>
    implements $UserConfigurationCopyWith<$Res> {
  _$UserConfigurationCopyWithImpl(this._self, this._then);

  final UserConfiguration _self;
  final $Res Function(UserConfiguration) _then;

/// Create a copy of UserConfiguration
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? audioLanguagePreference = freezed,Object? subtitleLanguagePreference = freezed,Object? subtitleMode = null,Object? playDefaultAudioTrack = null,Object? enableNextEpisodeAutoPlay = null,}) {
  return _then(_self.copyWith(
audioLanguagePreference: freezed == audioLanguagePreference ? _self.audioLanguagePreference : audioLanguagePreference // ignore: cast_nullable_to_non_nullable
as String?,subtitleLanguagePreference: freezed == subtitleLanguagePreference ? _self.subtitleLanguagePreference : subtitleLanguagePreference // ignore: cast_nullable_to_non_nullable
as String?,subtitleMode: null == subtitleMode ? _self.subtitleMode : subtitleMode // ignore: cast_nullable_to_non_nullable
as SubtitlePlaybackMode,playDefaultAudioTrack: null == playDefaultAudioTrack ? _self.playDefaultAudioTrack : playDefaultAudioTrack // ignore: cast_nullable_to_non_nullable
as bool,enableNextEpisodeAutoPlay: null == enableNextEpisodeAutoPlay ? _self.enableNextEpisodeAutoPlay : enableNextEpisodeAutoPlay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserConfiguration].
extension UserConfigurationPatterns on UserConfiguration {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserConfiguration value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserConfiguration() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserConfiguration value)  $default,){
final _that = this;
switch (_that) {
case _UserConfiguration():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserConfiguration value)?  $default,){
final _that = this;
switch (_that) {
case _UserConfiguration() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? audioLanguagePreference,  String? subtitleLanguagePreference, @JsonKey(unknownEnumValue: SubtitlePlaybackMode.defaultMode)  SubtitlePlaybackMode subtitleMode,  bool playDefaultAudioTrack,  bool enableNextEpisodeAutoPlay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserConfiguration() when $default != null:
return $default(_that.audioLanguagePreference,_that.subtitleLanguagePreference,_that.subtitleMode,_that.playDefaultAudioTrack,_that.enableNextEpisodeAutoPlay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? audioLanguagePreference,  String? subtitleLanguagePreference, @JsonKey(unknownEnumValue: SubtitlePlaybackMode.defaultMode)  SubtitlePlaybackMode subtitleMode,  bool playDefaultAudioTrack,  bool enableNextEpisodeAutoPlay)  $default,) {final _that = this;
switch (_that) {
case _UserConfiguration():
return $default(_that.audioLanguagePreference,_that.subtitleLanguagePreference,_that.subtitleMode,_that.playDefaultAudioTrack,_that.enableNextEpisodeAutoPlay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? audioLanguagePreference,  String? subtitleLanguagePreference, @JsonKey(unknownEnumValue: SubtitlePlaybackMode.defaultMode)  SubtitlePlaybackMode subtitleMode,  bool playDefaultAudioTrack,  bool enableNextEpisodeAutoPlay)?  $default,) {final _that = this;
switch (_that) {
case _UserConfiguration() when $default != null:
return $default(_that.audioLanguagePreference,_that.subtitleLanguagePreference,_that.subtitleMode,_that.playDefaultAudioTrack,_that.enableNextEpisodeAutoPlay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserConfiguration implements UserConfiguration {
  const _UserConfiguration({this.audioLanguagePreference, this.subtitleLanguagePreference, @JsonKey(unknownEnumValue: SubtitlePlaybackMode.defaultMode) this.subtitleMode = SubtitlePlaybackMode.defaultMode, this.playDefaultAudioTrack = true, this.enableNextEpisodeAutoPlay = true});
  factory _UserConfiguration.fromJson(Map<String, dynamic> json) => _$UserConfigurationFromJson(json);

/// ISO 639-2 code (e.g. "por"); null or empty = the file's default.
@override final  String? audioLanguagePreference;
@override final  String? subtitleLanguagePreference;
@override@JsonKey(unknownEnumValue: SubtitlePlaybackMode.defaultMode) final  SubtitlePlaybackMode subtitleMode;
@override@JsonKey() final  bool playDefaultAudioTrack;
@override@JsonKey() final  bool enableNextEpisodeAutoPlay;

/// Create a copy of UserConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserConfigurationCopyWith<_UserConfiguration> get copyWith => __$UserConfigurationCopyWithImpl<_UserConfiguration>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserConfigurationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserConfiguration&&(identical(other.audioLanguagePreference, audioLanguagePreference) || other.audioLanguagePreference == audioLanguagePreference)&&(identical(other.subtitleLanguagePreference, subtitleLanguagePreference) || other.subtitleLanguagePreference == subtitleLanguagePreference)&&(identical(other.subtitleMode, subtitleMode) || other.subtitleMode == subtitleMode)&&(identical(other.playDefaultAudioTrack, playDefaultAudioTrack) || other.playDefaultAudioTrack == playDefaultAudioTrack)&&(identical(other.enableNextEpisodeAutoPlay, enableNextEpisodeAutoPlay) || other.enableNextEpisodeAutoPlay == enableNextEpisodeAutoPlay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,audioLanguagePreference,subtitleLanguagePreference,subtitleMode,playDefaultAudioTrack,enableNextEpisodeAutoPlay);

@override
String toString() {
  return 'UserConfiguration(audioLanguagePreference: $audioLanguagePreference, subtitleLanguagePreference: $subtitleLanguagePreference, subtitleMode: $subtitleMode, playDefaultAudioTrack: $playDefaultAudioTrack, enableNextEpisodeAutoPlay: $enableNextEpisodeAutoPlay)';
}


}

/// @nodoc
abstract mixin class _$UserConfigurationCopyWith<$Res> implements $UserConfigurationCopyWith<$Res> {
  factory _$UserConfigurationCopyWith(_UserConfiguration value, $Res Function(_UserConfiguration) _then) = __$UserConfigurationCopyWithImpl;
@override @useResult
$Res call({
 String? audioLanguagePreference, String? subtitleLanguagePreference,@JsonKey(unknownEnumValue: SubtitlePlaybackMode.defaultMode) SubtitlePlaybackMode subtitleMode, bool playDefaultAudioTrack, bool enableNextEpisodeAutoPlay
});




}
/// @nodoc
class __$UserConfigurationCopyWithImpl<$Res>
    implements _$UserConfigurationCopyWith<$Res> {
  __$UserConfigurationCopyWithImpl(this._self, this._then);

  final _UserConfiguration _self;
  final $Res Function(_UserConfiguration) _then;

/// Create a copy of UserConfiguration
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? audioLanguagePreference = freezed,Object? subtitleLanguagePreference = freezed,Object? subtitleMode = null,Object? playDefaultAudioTrack = null,Object? enableNextEpisodeAutoPlay = null,}) {
  return _then(_UserConfiguration(
audioLanguagePreference: freezed == audioLanguagePreference ? _self.audioLanguagePreference : audioLanguagePreference // ignore: cast_nullable_to_non_nullable
as String?,subtitleLanguagePreference: freezed == subtitleLanguagePreference ? _self.subtitleLanguagePreference : subtitleLanguagePreference // ignore: cast_nullable_to_non_nullable
as String?,subtitleMode: null == subtitleMode ? _self.subtitleMode : subtitleMode // ignore: cast_nullable_to_non_nullable
as SubtitlePlaybackMode,playDefaultAudioTrack: null == playDefaultAudioTrack ? _self.playDefaultAudioTrack : playDefaultAudioTrack // ignore: cast_nullable_to_non_nullable
as bool,enableNextEpisodeAutoPlay: null == enableNextEpisodeAutoPlay ? _self.enableNextEpisodeAutoPlay : enableNextEpisodeAutoPlay // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
