// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DeviceProfile {

 String get name; int? get maxStaticBitrate; int? get maxStreamingBitrate; int? get musicStreamingTranscodingBitrate; List<DirectPlayProfile> get directPlayProfiles; List<TranscodingProfile> get transcodingProfiles; List<SubtitleProfile> get subtitleProfiles;
/// Create a copy of DeviceProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DeviceProfileCopyWith<DeviceProfile> get copyWith => _$DeviceProfileCopyWithImpl<DeviceProfile>(this as DeviceProfile, _$identity);

  /// Serializes this DeviceProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DeviceProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.maxStaticBitrate, maxStaticBitrate) || other.maxStaticBitrate == maxStaticBitrate)&&(identical(other.maxStreamingBitrate, maxStreamingBitrate) || other.maxStreamingBitrate == maxStreamingBitrate)&&(identical(other.musicStreamingTranscodingBitrate, musicStreamingTranscodingBitrate) || other.musicStreamingTranscodingBitrate == musicStreamingTranscodingBitrate)&&const DeepCollectionEquality().equals(other.directPlayProfiles, directPlayProfiles)&&const DeepCollectionEquality().equals(other.transcodingProfiles, transcodingProfiles)&&const DeepCollectionEquality().equals(other.subtitleProfiles, subtitleProfiles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,maxStaticBitrate,maxStreamingBitrate,musicStreamingTranscodingBitrate,const DeepCollectionEquality().hash(directPlayProfiles),const DeepCollectionEquality().hash(transcodingProfiles),const DeepCollectionEquality().hash(subtitleProfiles));

@override
String toString() {
  return 'DeviceProfile(name: $name, maxStaticBitrate: $maxStaticBitrate, maxStreamingBitrate: $maxStreamingBitrate, musicStreamingTranscodingBitrate: $musicStreamingTranscodingBitrate, directPlayProfiles: $directPlayProfiles, transcodingProfiles: $transcodingProfiles, subtitleProfiles: $subtitleProfiles)';
}


}

/// @nodoc
abstract mixin class $DeviceProfileCopyWith<$Res>  {
  factory $DeviceProfileCopyWith(DeviceProfile value, $Res Function(DeviceProfile) _then) = _$DeviceProfileCopyWithImpl;
@useResult
$Res call({
 String name, int? maxStaticBitrate, int? maxStreamingBitrate, int? musicStreamingTranscodingBitrate, List<DirectPlayProfile> directPlayProfiles, List<TranscodingProfile> transcodingProfiles, List<SubtitleProfile> subtitleProfiles
});




}
/// @nodoc
class _$DeviceProfileCopyWithImpl<$Res>
    implements $DeviceProfileCopyWith<$Res> {
  _$DeviceProfileCopyWithImpl(this._self, this._then);

  final DeviceProfile _self;
  final $Res Function(DeviceProfile) _then;

/// Create a copy of DeviceProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? maxStaticBitrate = freezed,Object? maxStreamingBitrate = freezed,Object? musicStreamingTranscodingBitrate = freezed,Object? directPlayProfiles = null,Object? transcodingProfiles = null,Object? subtitleProfiles = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,maxStaticBitrate: freezed == maxStaticBitrate ? _self.maxStaticBitrate : maxStaticBitrate // ignore: cast_nullable_to_non_nullable
as int?,maxStreamingBitrate: freezed == maxStreamingBitrate ? _self.maxStreamingBitrate : maxStreamingBitrate // ignore: cast_nullable_to_non_nullable
as int?,musicStreamingTranscodingBitrate: freezed == musicStreamingTranscodingBitrate ? _self.musicStreamingTranscodingBitrate : musicStreamingTranscodingBitrate // ignore: cast_nullable_to_non_nullable
as int?,directPlayProfiles: null == directPlayProfiles ? _self.directPlayProfiles : directPlayProfiles // ignore: cast_nullable_to_non_nullable
as List<DirectPlayProfile>,transcodingProfiles: null == transcodingProfiles ? _self.transcodingProfiles : transcodingProfiles // ignore: cast_nullable_to_non_nullable
as List<TranscodingProfile>,subtitleProfiles: null == subtitleProfiles ? _self.subtitleProfiles : subtitleProfiles // ignore: cast_nullable_to_non_nullable
as List<SubtitleProfile>,
  ));
}

}


/// Adds pattern-matching-related methods to [DeviceProfile].
extension DeviceProfilePatterns on DeviceProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DeviceProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DeviceProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DeviceProfile value)  $default,){
final _that = this;
switch (_that) {
case _DeviceProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DeviceProfile value)?  $default,){
final _that = this;
switch (_that) {
case _DeviceProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int? maxStaticBitrate,  int? maxStreamingBitrate,  int? musicStreamingTranscodingBitrate,  List<DirectPlayProfile> directPlayProfiles,  List<TranscodingProfile> transcodingProfiles,  List<SubtitleProfile> subtitleProfiles)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DeviceProfile() when $default != null:
return $default(_that.name,_that.maxStaticBitrate,_that.maxStreamingBitrate,_that.musicStreamingTranscodingBitrate,_that.directPlayProfiles,_that.transcodingProfiles,_that.subtitleProfiles);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int? maxStaticBitrate,  int? maxStreamingBitrate,  int? musicStreamingTranscodingBitrate,  List<DirectPlayProfile> directPlayProfiles,  List<TranscodingProfile> transcodingProfiles,  List<SubtitleProfile> subtitleProfiles)  $default,) {final _that = this;
switch (_that) {
case _DeviceProfile():
return $default(_that.name,_that.maxStaticBitrate,_that.maxStreamingBitrate,_that.musicStreamingTranscodingBitrate,_that.directPlayProfiles,_that.transcodingProfiles,_that.subtitleProfiles);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int? maxStaticBitrate,  int? maxStreamingBitrate,  int? musicStreamingTranscodingBitrate,  List<DirectPlayProfile> directPlayProfiles,  List<TranscodingProfile> transcodingProfiles,  List<SubtitleProfile> subtitleProfiles)?  $default,) {final _that = this;
switch (_that) {
case _DeviceProfile() when $default != null:
return $default(_that.name,_that.maxStaticBitrate,_that.maxStreamingBitrate,_that.musicStreamingTranscodingBitrate,_that.directPlayProfiles,_that.transcodingProfiles,_that.subtitleProfiles);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DeviceProfile implements DeviceProfile {
  const _DeviceProfile({required this.name, this.maxStaticBitrate, this.maxStreamingBitrate, this.musicStreamingTranscodingBitrate, this.directPlayProfiles = const [], this.transcodingProfiles = const [], this.subtitleProfiles = const []});
  factory _DeviceProfile.fromJson(Map<String, dynamic> json) => _$DeviceProfileFromJson(json);

@override final  String name;
@override final  int? maxStaticBitrate;
@override final  int? maxStreamingBitrate;
@override final  int? musicStreamingTranscodingBitrate;
@override@JsonKey() final  List<DirectPlayProfile> directPlayProfiles;
@override@JsonKey() final  List<TranscodingProfile> transcodingProfiles;
@override@JsonKey() final  List<SubtitleProfile> subtitleProfiles;

/// Create a copy of DeviceProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DeviceProfileCopyWith<_DeviceProfile> get copyWith => __$DeviceProfileCopyWithImpl<_DeviceProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DeviceProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DeviceProfile&&(identical(other.name, name) || other.name == name)&&(identical(other.maxStaticBitrate, maxStaticBitrate) || other.maxStaticBitrate == maxStaticBitrate)&&(identical(other.maxStreamingBitrate, maxStreamingBitrate) || other.maxStreamingBitrate == maxStreamingBitrate)&&(identical(other.musicStreamingTranscodingBitrate, musicStreamingTranscodingBitrate) || other.musicStreamingTranscodingBitrate == musicStreamingTranscodingBitrate)&&const DeepCollectionEquality().equals(other.directPlayProfiles, directPlayProfiles)&&const DeepCollectionEquality().equals(other.transcodingProfiles, transcodingProfiles)&&const DeepCollectionEquality().equals(other.subtitleProfiles, subtitleProfiles));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,maxStaticBitrate,maxStreamingBitrate,musicStreamingTranscodingBitrate,const DeepCollectionEquality().hash(directPlayProfiles),const DeepCollectionEquality().hash(transcodingProfiles),const DeepCollectionEquality().hash(subtitleProfiles));

@override
String toString() {
  return 'DeviceProfile(name: $name, maxStaticBitrate: $maxStaticBitrate, maxStreamingBitrate: $maxStreamingBitrate, musicStreamingTranscodingBitrate: $musicStreamingTranscodingBitrate, directPlayProfiles: $directPlayProfiles, transcodingProfiles: $transcodingProfiles, subtitleProfiles: $subtitleProfiles)';
}


}

/// @nodoc
abstract mixin class _$DeviceProfileCopyWith<$Res> implements $DeviceProfileCopyWith<$Res> {
  factory _$DeviceProfileCopyWith(_DeviceProfile value, $Res Function(_DeviceProfile) _then) = __$DeviceProfileCopyWithImpl;
@override @useResult
$Res call({
 String name, int? maxStaticBitrate, int? maxStreamingBitrate, int? musicStreamingTranscodingBitrate, List<DirectPlayProfile> directPlayProfiles, List<TranscodingProfile> transcodingProfiles, List<SubtitleProfile> subtitleProfiles
});




}
/// @nodoc
class __$DeviceProfileCopyWithImpl<$Res>
    implements _$DeviceProfileCopyWith<$Res> {
  __$DeviceProfileCopyWithImpl(this._self, this._then);

  final _DeviceProfile _self;
  final $Res Function(_DeviceProfile) _then;

/// Create a copy of DeviceProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? maxStaticBitrate = freezed,Object? maxStreamingBitrate = freezed,Object? musicStreamingTranscodingBitrate = freezed,Object? directPlayProfiles = null,Object? transcodingProfiles = null,Object? subtitleProfiles = null,}) {
  return _then(_DeviceProfile(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,maxStaticBitrate: freezed == maxStaticBitrate ? _self.maxStaticBitrate : maxStaticBitrate // ignore: cast_nullable_to_non_nullable
as int?,maxStreamingBitrate: freezed == maxStreamingBitrate ? _self.maxStreamingBitrate : maxStreamingBitrate // ignore: cast_nullable_to_non_nullable
as int?,musicStreamingTranscodingBitrate: freezed == musicStreamingTranscodingBitrate ? _self.musicStreamingTranscodingBitrate : musicStreamingTranscodingBitrate // ignore: cast_nullable_to_non_nullable
as int?,directPlayProfiles: null == directPlayProfiles ? _self.directPlayProfiles : directPlayProfiles // ignore: cast_nullable_to_non_nullable
as List<DirectPlayProfile>,transcodingProfiles: null == transcodingProfiles ? _self.transcodingProfiles : transcodingProfiles // ignore: cast_nullable_to_non_nullable
as List<TranscodingProfile>,subtitleProfiles: null == subtitleProfiles ? _self.subtitleProfiles : subtitleProfiles // ignore: cast_nullable_to_non_nullable
as List<SubtitleProfile>,
  ));
}


}


/// @nodoc
mixin _$DirectPlayProfile {

 String get type; String? get container; String? get videoCodec; String? get audioCodec;
/// Create a copy of DirectPlayProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DirectPlayProfileCopyWith<DirectPlayProfile> get copyWith => _$DirectPlayProfileCopyWithImpl<DirectPlayProfile>(this as DirectPlayProfile, _$identity);

  /// Serializes this DirectPlayProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DirectPlayProfile&&(identical(other.type, type) || other.type == type)&&(identical(other.container, container) || other.container == container)&&(identical(other.videoCodec, videoCodec) || other.videoCodec == videoCodec)&&(identical(other.audioCodec, audioCodec) || other.audioCodec == audioCodec));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,container,videoCodec,audioCodec);

@override
String toString() {
  return 'DirectPlayProfile(type: $type, container: $container, videoCodec: $videoCodec, audioCodec: $audioCodec)';
}


}

/// @nodoc
abstract mixin class $DirectPlayProfileCopyWith<$Res>  {
  factory $DirectPlayProfileCopyWith(DirectPlayProfile value, $Res Function(DirectPlayProfile) _then) = _$DirectPlayProfileCopyWithImpl;
@useResult
$Res call({
 String type, String? container, String? videoCodec, String? audioCodec
});




}
/// @nodoc
class _$DirectPlayProfileCopyWithImpl<$Res>
    implements $DirectPlayProfileCopyWith<$Res> {
  _$DirectPlayProfileCopyWithImpl(this._self, this._then);

  final DirectPlayProfile _self;
  final $Res Function(DirectPlayProfile) _then;

/// Create a copy of DirectPlayProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? container = freezed,Object? videoCodec = freezed,Object? audioCodec = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,container: freezed == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as String?,videoCodec: freezed == videoCodec ? _self.videoCodec : videoCodec // ignore: cast_nullable_to_non_nullable
as String?,audioCodec: freezed == audioCodec ? _self.audioCodec : audioCodec // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DirectPlayProfile].
extension DirectPlayProfilePatterns on DirectPlayProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DirectPlayProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DirectPlayProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DirectPlayProfile value)  $default,){
final _that = this;
switch (_that) {
case _DirectPlayProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DirectPlayProfile value)?  $default,){
final _that = this;
switch (_that) {
case _DirectPlayProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String? container,  String? videoCodec,  String? audioCodec)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DirectPlayProfile() when $default != null:
return $default(_that.type,_that.container,_that.videoCodec,_that.audioCodec);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String? container,  String? videoCodec,  String? audioCodec)  $default,) {final _that = this;
switch (_that) {
case _DirectPlayProfile():
return $default(_that.type,_that.container,_that.videoCodec,_that.audioCodec);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String? container,  String? videoCodec,  String? audioCodec)?  $default,) {final _that = this;
switch (_that) {
case _DirectPlayProfile() when $default != null:
return $default(_that.type,_that.container,_that.videoCodec,_that.audioCodec);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DirectPlayProfile implements DirectPlayProfile {
  const _DirectPlayProfile({required this.type, this.container, this.videoCodec, this.audioCodec});
  factory _DirectPlayProfile.fromJson(Map<String, dynamic> json) => _$DirectPlayProfileFromJson(json);

@override final  String type;
@override final  String? container;
@override final  String? videoCodec;
@override final  String? audioCodec;

/// Create a copy of DirectPlayProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DirectPlayProfileCopyWith<_DirectPlayProfile> get copyWith => __$DirectPlayProfileCopyWithImpl<_DirectPlayProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DirectPlayProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DirectPlayProfile&&(identical(other.type, type) || other.type == type)&&(identical(other.container, container) || other.container == container)&&(identical(other.videoCodec, videoCodec) || other.videoCodec == videoCodec)&&(identical(other.audioCodec, audioCodec) || other.audioCodec == audioCodec));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,container,videoCodec,audioCodec);

@override
String toString() {
  return 'DirectPlayProfile(type: $type, container: $container, videoCodec: $videoCodec, audioCodec: $audioCodec)';
}


}

/// @nodoc
abstract mixin class _$DirectPlayProfileCopyWith<$Res> implements $DirectPlayProfileCopyWith<$Res> {
  factory _$DirectPlayProfileCopyWith(_DirectPlayProfile value, $Res Function(_DirectPlayProfile) _then) = __$DirectPlayProfileCopyWithImpl;
@override @useResult
$Res call({
 String type, String? container, String? videoCodec, String? audioCodec
});




}
/// @nodoc
class __$DirectPlayProfileCopyWithImpl<$Res>
    implements _$DirectPlayProfileCopyWith<$Res> {
  __$DirectPlayProfileCopyWithImpl(this._self, this._then);

  final _DirectPlayProfile _self;
  final $Res Function(_DirectPlayProfile) _then;

/// Create a copy of DirectPlayProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? container = freezed,Object? videoCodec = freezed,Object? audioCodec = freezed,}) {
  return _then(_DirectPlayProfile(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,container: freezed == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as String?,videoCodec: freezed == videoCodec ? _self.videoCodec : videoCodec // ignore: cast_nullable_to_non_nullable
as String?,audioCodec: freezed == audioCodec ? _self.audioCodec : audioCodec // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TranscodingProfile {

 String get type; String? get container; String? get protocol; String? get videoCodec; String? get audioCodec; String? get maxAudioChannels;
/// Create a copy of TranscodingProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TranscodingProfileCopyWith<TranscodingProfile> get copyWith => _$TranscodingProfileCopyWithImpl<TranscodingProfile>(this as TranscodingProfile, _$identity);

  /// Serializes this TranscodingProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TranscodingProfile&&(identical(other.type, type) || other.type == type)&&(identical(other.container, container) || other.container == container)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.videoCodec, videoCodec) || other.videoCodec == videoCodec)&&(identical(other.audioCodec, audioCodec) || other.audioCodec == audioCodec)&&(identical(other.maxAudioChannels, maxAudioChannels) || other.maxAudioChannels == maxAudioChannels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,container,protocol,videoCodec,audioCodec,maxAudioChannels);

@override
String toString() {
  return 'TranscodingProfile(type: $type, container: $container, protocol: $protocol, videoCodec: $videoCodec, audioCodec: $audioCodec, maxAudioChannels: $maxAudioChannels)';
}


}

/// @nodoc
abstract mixin class $TranscodingProfileCopyWith<$Res>  {
  factory $TranscodingProfileCopyWith(TranscodingProfile value, $Res Function(TranscodingProfile) _then) = _$TranscodingProfileCopyWithImpl;
@useResult
$Res call({
 String type, String? container, String? protocol, String? videoCodec, String? audioCodec, String? maxAudioChannels
});




}
/// @nodoc
class _$TranscodingProfileCopyWithImpl<$Res>
    implements $TranscodingProfileCopyWith<$Res> {
  _$TranscodingProfileCopyWithImpl(this._self, this._then);

  final TranscodingProfile _self;
  final $Res Function(TranscodingProfile) _then;

/// Create a copy of TranscodingProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? container = freezed,Object? protocol = freezed,Object? videoCodec = freezed,Object? audioCodec = freezed,Object? maxAudioChannels = freezed,}) {
  return _then(_self.copyWith(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,container: freezed == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as String?,protocol: freezed == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String?,videoCodec: freezed == videoCodec ? _self.videoCodec : videoCodec // ignore: cast_nullable_to_non_nullable
as String?,audioCodec: freezed == audioCodec ? _self.audioCodec : audioCodec // ignore: cast_nullable_to_non_nullable
as String?,maxAudioChannels: freezed == maxAudioChannels ? _self.maxAudioChannels : maxAudioChannels // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TranscodingProfile].
extension TranscodingProfilePatterns on TranscodingProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TranscodingProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TranscodingProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TranscodingProfile value)  $default,){
final _that = this;
switch (_that) {
case _TranscodingProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TranscodingProfile value)?  $default,){
final _that = this;
switch (_that) {
case _TranscodingProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String type,  String? container,  String? protocol,  String? videoCodec,  String? audioCodec,  String? maxAudioChannels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TranscodingProfile() when $default != null:
return $default(_that.type,_that.container,_that.protocol,_that.videoCodec,_that.audioCodec,_that.maxAudioChannels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String type,  String? container,  String? protocol,  String? videoCodec,  String? audioCodec,  String? maxAudioChannels)  $default,) {final _that = this;
switch (_that) {
case _TranscodingProfile():
return $default(_that.type,_that.container,_that.protocol,_that.videoCodec,_that.audioCodec,_that.maxAudioChannels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String type,  String? container,  String? protocol,  String? videoCodec,  String? audioCodec,  String? maxAudioChannels)?  $default,) {final _that = this;
switch (_that) {
case _TranscodingProfile() when $default != null:
return $default(_that.type,_that.container,_that.protocol,_that.videoCodec,_that.audioCodec,_that.maxAudioChannels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TranscodingProfile implements TranscodingProfile {
  const _TranscodingProfile({required this.type, this.container, this.protocol, this.videoCodec, this.audioCodec, this.maxAudioChannels});
  factory _TranscodingProfile.fromJson(Map<String, dynamic> json) => _$TranscodingProfileFromJson(json);

@override final  String type;
@override final  String? container;
@override final  String? protocol;
@override final  String? videoCodec;
@override final  String? audioCodec;
@override final  String? maxAudioChannels;

/// Create a copy of TranscodingProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TranscodingProfileCopyWith<_TranscodingProfile> get copyWith => __$TranscodingProfileCopyWithImpl<_TranscodingProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TranscodingProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TranscodingProfile&&(identical(other.type, type) || other.type == type)&&(identical(other.container, container) || other.container == container)&&(identical(other.protocol, protocol) || other.protocol == protocol)&&(identical(other.videoCodec, videoCodec) || other.videoCodec == videoCodec)&&(identical(other.audioCodec, audioCodec) || other.audioCodec == audioCodec)&&(identical(other.maxAudioChannels, maxAudioChannels) || other.maxAudioChannels == maxAudioChannels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,type,container,protocol,videoCodec,audioCodec,maxAudioChannels);

@override
String toString() {
  return 'TranscodingProfile(type: $type, container: $container, protocol: $protocol, videoCodec: $videoCodec, audioCodec: $audioCodec, maxAudioChannels: $maxAudioChannels)';
}


}

/// @nodoc
abstract mixin class _$TranscodingProfileCopyWith<$Res> implements $TranscodingProfileCopyWith<$Res> {
  factory _$TranscodingProfileCopyWith(_TranscodingProfile value, $Res Function(_TranscodingProfile) _then) = __$TranscodingProfileCopyWithImpl;
@override @useResult
$Res call({
 String type, String? container, String? protocol, String? videoCodec, String? audioCodec, String? maxAudioChannels
});




}
/// @nodoc
class __$TranscodingProfileCopyWithImpl<$Res>
    implements _$TranscodingProfileCopyWith<$Res> {
  __$TranscodingProfileCopyWithImpl(this._self, this._then);

  final _TranscodingProfile _self;
  final $Res Function(_TranscodingProfile) _then;

/// Create a copy of TranscodingProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? container = freezed,Object? protocol = freezed,Object? videoCodec = freezed,Object? audioCodec = freezed,Object? maxAudioChannels = freezed,}) {
  return _then(_TranscodingProfile(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as String,container: freezed == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as String?,protocol: freezed == protocol ? _self.protocol : protocol // ignore: cast_nullable_to_non_nullable
as String?,videoCodec: freezed == videoCodec ? _self.videoCodec : videoCodec // ignore: cast_nullable_to_non_nullable
as String?,audioCodec: freezed == audioCodec ? _self.audioCodec : audioCodec // ignore: cast_nullable_to_non_nullable
as String?,maxAudioChannels: freezed == maxAudioChannels ? _self.maxAudioChannels : maxAudioChannels // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$SubtitleProfile {

 String get format; String get method;
/// Create a copy of SubtitleProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubtitleProfileCopyWith<SubtitleProfile> get copyWith => _$SubtitleProfileCopyWithImpl<SubtitleProfile>(this as SubtitleProfile, _$identity);

  /// Serializes this SubtitleProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubtitleProfile&&(identical(other.format, format) || other.format == format)&&(identical(other.method, method) || other.method == method));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,method);

@override
String toString() {
  return 'SubtitleProfile(format: $format, method: $method)';
}


}

/// @nodoc
abstract mixin class $SubtitleProfileCopyWith<$Res>  {
  factory $SubtitleProfileCopyWith(SubtitleProfile value, $Res Function(SubtitleProfile) _then) = _$SubtitleProfileCopyWithImpl;
@useResult
$Res call({
 String format, String method
});




}
/// @nodoc
class _$SubtitleProfileCopyWithImpl<$Res>
    implements $SubtitleProfileCopyWith<$Res> {
  _$SubtitleProfileCopyWithImpl(this._self, this._then);

  final SubtitleProfile _self;
  final $Res Function(SubtitleProfile) _then;

/// Create a copy of SubtitleProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? format = null,Object? method = null,}) {
  return _then(_self.copyWith(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SubtitleProfile].
extension SubtitleProfilePatterns on SubtitleProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubtitleProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubtitleProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubtitleProfile value)  $default,){
final _that = this;
switch (_that) {
case _SubtitleProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubtitleProfile value)?  $default,){
final _that = this;
switch (_that) {
case _SubtitleProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String format,  String method)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubtitleProfile() when $default != null:
return $default(_that.format,_that.method);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String format,  String method)  $default,) {final _that = this;
switch (_that) {
case _SubtitleProfile():
return $default(_that.format,_that.method);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String format,  String method)?  $default,) {final _that = this;
switch (_that) {
case _SubtitleProfile() when $default != null:
return $default(_that.format,_that.method);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SubtitleProfile implements SubtitleProfile {
  const _SubtitleProfile({required this.format, required this.method});
  factory _SubtitleProfile.fromJson(Map<String, dynamic> json) => _$SubtitleProfileFromJson(json);

@override final  String format;
@override final  String method;

/// Create a copy of SubtitleProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubtitleProfileCopyWith<_SubtitleProfile> get copyWith => __$SubtitleProfileCopyWithImpl<_SubtitleProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SubtitleProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubtitleProfile&&(identical(other.format, format) || other.format == format)&&(identical(other.method, method) || other.method == method));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,format,method);

@override
String toString() {
  return 'SubtitleProfile(format: $format, method: $method)';
}


}

/// @nodoc
abstract mixin class _$SubtitleProfileCopyWith<$Res> implements $SubtitleProfileCopyWith<$Res> {
  factory _$SubtitleProfileCopyWith(_SubtitleProfile value, $Res Function(_SubtitleProfile) _then) = __$SubtitleProfileCopyWithImpl;
@override @useResult
$Res call({
 String format, String method
});




}
/// @nodoc
class __$SubtitleProfileCopyWithImpl<$Res>
    implements _$SubtitleProfileCopyWith<$Res> {
  __$SubtitleProfileCopyWithImpl(this._self, this._then);

  final _SubtitleProfile _self;
  final $Res Function(_SubtitleProfile) _then;

/// Create a copy of SubtitleProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? format = null,Object? method = null,}) {
  return _then(_SubtitleProfile(
format: null == format ? _self.format : format // ignore: cast_nullable_to_non_nullable
as String,method: null == method ? _self.method : method // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
