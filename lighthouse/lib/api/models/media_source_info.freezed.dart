// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_source_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaSourceInfo {

 String get id; String? get container; int? get runTimeTicks; bool get supportsDirectPlay; bool get supportsDirectStream; bool get supportsTranscoding;/// Server-relative URL of a transcoded stream, when the server decided
/// one is needed. It carries an access token: never log it.
 String? get transcodingUrl; List<MediaStream> get mediaStreams; int? get defaultAudioStreamIndex; int? get defaultSubtitleStreamIndex;
/// Create a copy of MediaSourceInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaSourceInfoCopyWith<MediaSourceInfo> get copyWith => _$MediaSourceInfoCopyWithImpl<MediaSourceInfo>(this as MediaSourceInfo, _$identity);

  /// Serializes this MediaSourceInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaSourceInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.container, container) || other.container == container)&&(identical(other.runTimeTicks, runTimeTicks) || other.runTimeTicks == runTimeTicks)&&(identical(other.supportsDirectPlay, supportsDirectPlay) || other.supportsDirectPlay == supportsDirectPlay)&&(identical(other.supportsDirectStream, supportsDirectStream) || other.supportsDirectStream == supportsDirectStream)&&(identical(other.supportsTranscoding, supportsTranscoding) || other.supportsTranscoding == supportsTranscoding)&&(identical(other.transcodingUrl, transcodingUrl) || other.transcodingUrl == transcodingUrl)&&const DeepCollectionEquality().equals(other.mediaStreams, mediaStreams)&&(identical(other.defaultAudioStreamIndex, defaultAudioStreamIndex) || other.defaultAudioStreamIndex == defaultAudioStreamIndex)&&(identical(other.defaultSubtitleStreamIndex, defaultSubtitleStreamIndex) || other.defaultSubtitleStreamIndex == defaultSubtitleStreamIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,container,runTimeTicks,supportsDirectPlay,supportsDirectStream,supportsTranscoding,transcodingUrl,const DeepCollectionEquality().hash(mediaStreams),defaultAudioStreamIndex,defaultSubtitleStreamIndex);

@override
String toString() {
  return 'MediaSourceInfo(id: $id, container: $container, runTimeTicks: $runTimeTicks, supportsDirectPlay: $supportsDirectPlay, supportsDirectStream: $supportsDirectStream, supportsTranscoding: $supportsTranscoding, transcodingUrl: $transcodingUrl, mediaStreams: $mediaStreams, defaultAudioStreamIndex: $defaultAudioStreamIndex, defaultSubtitleStreamIndex: $defaultSubtitleStreamIndex)';
}


}

/// @nodoc
abstract mixin class $MediaSourceInfoCopyWith<$Res>  {
  factory $MediaSourceInfoCopyWith(MediaSourceInfo value, $Res Function(MediaSourceInfo) _then) = _$MediaSourceInfoCopyWithImpl;
@useResult
$Res call({
 String id, String? container, int? runTimeTicks, bool supportsDirectPlay, bool supportsDirectStream, bool supportsTranscoding, String? transcodingUrl, List<MediaStream> mediaStreams, int? defaultAudioStreamIndex, int? defaultSubtitleStreamIndex
});




}
/// @nodoc
class _$MediaSourceInfoCopyWithImpl<$Res>
    implements $MediaSourceInfoCopyWith<$Res> {
  _$MediaSourceInfoCopyWithImpl(this._self, this._then);

  final MediaSourceInfo _self;
  final $Res Function(MediaSourceInfo) _then;

/// Create a copy of MediaSourceInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? container = freezed,Object? runTimeTicks = freezed,Object? supportsDirectPlay = null,Object? supportsDirectStream = null,Object? supportsTranscoding = null,Object? transcodingUrl = freezed,Object? mediaStreams = null,Object? defaultAudioStreamIndex = freezed,Object? defaultSubtitleStreamIndex = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,container: freezed == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as String?,runTimeTicks: freezed == runTimeTicks ? _self.runTimeTicks : runTimeTicks // ignore: cast_nullable_to_non_nullable
as int?,supportsDirectPlay: null == supportsDirectPlay ? _self.supportsDirectPlay : supportsDirectPlay // ignore: cast_nullable_to_non_nullable
as bool,supportsDirectStream: null == supportsDirectStream ? _self.supportsDirectStream : supportsDirectStream // ignore: cast_nullable_to_non_nullable
as bool,supportsTranscoding: null == supportsTranscoding ? _self.supportsTranscoding : supportsTranscoding // ignore: cast_nullable_to_non_nullable
as bool,transcodingUrl: freezed == transcodingUrl ? _self.transcodingUrl : transcodingUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaStreams: null == mediaStreams ? _self.mediaStreams : mediaStreams // ignore: cast_nullable_to_non_nullable
as List<MediaStream>,defaultAudioStreamIndex: freezed == defaultAudioStreamIndex ? _self.defaultAudioStreamIndex : defaultAudioStreamIndex // ignore: cast_nullable_to_non_nullable
as int?,defaultSubtitleStreamIndex: freezed == defaultSubtitleStreamIndex ? _self.defaultSubtitleStreamIndex : defaultSubtitleStreamIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaSourceInfo].
extension MediaSourceInfoPatterns on MediaSourceInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaSourceInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaSourceInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaSourceInfo value)  $default,){
final _that = this;
switch (_that) {
case _MediaSourceInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaSourceInfo value)?  $default,){
final _that = this;
switch (_that) {
case _MediaSourceInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? container,  int? runTimeTicks,  bool supportsDirectPlay,  bool supportsDirectStream,  bool supportsTranscoding,  String? transcodingUrl,  List<MediaStream> mediaStreams,  int? defaultAudioStreamIndex,  int? defaultSubtitleStreamIndex)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaSourceInfo() when $default != null:
return $default(_that.id,_that.container,_that.runTimeTicks,_that.supportsDirectPlay,_that.supportsDirectStream,_that.supportsTranscoding,_that.transcodingUrl,_that.mediaStreams,_that.defaultAudioStreamIndex,_that.defaultSubtitleStreamIndex);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? container,  int? runTimeTicks,  bool supportsDirectPlay,  bool supportsDirectStream,  bool supportsTranscoding,  String? transcodingUrl,  List<MediaStream> mediaStreams,  int? defaultAudioStreamIndex,  int? defaultSubtitleStreamIndex)  $default,) {final _that = this;
switch (_that) {
case _MediaSourceInfo():
return $default(_that.id,_that.container,_that.runTimeTicks,_that.supportsDirectPlay,_that.supportsDirectStream,_that.supportsTranscoding,_that.transcodingUrl,_that.mediaStreams,_that.defaultAudioStreamIndex,_that.defaultSubtitleStreamIndex);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? container,  int? runTimeTicks,  bool supportsDirectPlay,  bool supportsDirectStream,  bool supportsTranscoding,  String? transcodingUrl,  List<MediaStream> mediaStreams,  int? defaultAudioStreamIndex,  int? defaultSubtitleStreamIndex)?  $default,) {final _that = this;
switch (_that) {
case _MediaSourceInfo() when $default != null:
return $default(_that.id,_that.container,_that.runTimeTicks,_that.supportsDirectPlay,_that.supportsDirectStream,_that.supportsTranscoding,_that.transcodingUrl,_that.mediaStreams,_that.defaultAudioStreamIndex,_that.defaultSubtitleStreamIndex);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaSourceInfo implements MediaSourceInfo {
  const _MediaSourceInfo({required this.id, this.container, this.runTimeTicks, this.supportsDirectPlay = false, this.supportsDirectStream = false, this.supportsTranscoding = false, this.transcodingUrl, this.mediaStreams = const [], this.defaultAudioStreamIndex, this.defaultSubtitleStreamIndex});
  factory _MediaSourceInfo.fromJson(Map<String, dynamic> json) => _$MediaSourceInfoFromJson(json);

@override final  String id;
@override final  String? container;
@override final  int? runTimeTicks;
@override@JsonKey() final  bool supportsDirectPlay;
@override@JsonKey() final  bool supportsDirectStream;
@override@JsonKey() final  bool supportsTranscoding;
/// Server-relative URL of a transcoded stream, when the server decided
/// one is needed. It carries an access token: never log it.
@override final  String? transcodingUrl;
@override@JsonKey() final  List<MediaStream> mediaStreams;
@override final  int? defaultAudioStreamIndex;
@override final  int? defaultSubtitleStreamIndex;

/// Create a copy of MediaSourceInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaSourceInfoCopyWith<_MediaSourceInfo> get copyWith => __$MediaSourceInfoCopyWithImpl<_MediaSourceInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaSourceInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaSourceInfo&&(identical(other.id, id) || other.id == id)&&(identical(other.container, container) || other.container == container)&&(identical(other.runTimeTicks, runTimeTicks) || other.runTimeTicks == runTimeTicks)&&(identical(other.supportsDirectPlay, supportsDirectPlay) || other.supportsDirectPlay == supportsDirectPlay)&&(identical(other.supportsDirectStream, supportsDirectStream) || other.supportsDirectStream == supportsDirectStream)&&(identical(other.supportsTranscoding, supportsTranscoding) || other.supportsTranscoding == supportsTranscoding)&&(identical(other.transcodingUrl, transcodingUrl) || other.transcodingUrl == transcodingUrl)&&const DeepCollectionEquality().equals(other.mediaStreams, mediaStreams)&&(identical(other.defaultAudioStreamIndex, defaultAudioStreamIndex) || other.defaultAudioStreamIndex == defaultAudioStreamIndex)&&(identical(other.defaultSubtitleStreamIndex, defaultSubtitleStreamIndex) || other.defaultSubtitleStreamIndex == defaultSubtitleStreamIndex));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,container,runTimeTicks,supportsDirectPlay,supportsDirectStream,supportsTranscoding,transcodingUrl,const DeepCollectionEquality().hash(mediaStreams),defaultAudioStreamIndex,defaultSubtitleStreamIndex);

@override
String toString() {
  return 'MediaSourceInfo(id: $id, container: $container, runTimeTicks: $runTimeTicks, supportsDirectPlay: $supportsDirectPlay, supportsDirectStream: $supportsDirectStream, supportsTranscoding: $supportsTranscoding, transcodingUrl: $transcodingUrl, mediaStreams: $mediaStreams, defaultAudioStreamIndex: $defaultAudioStreamIndex, defaultSubtitleStreamIndex: $defaultSubtitleStreamIndex)';
}


}

/// @nodoc
abstract mixin class _$MediaSourceInfoCopyWith<$Res> implements $MediaSourceInfoCopyWith<$Res> {
  factory _$MediaSourceInfoCopyWith(_MediaSourceInfo value, $Res Function(_MediaSourceInfo) _then) = __$MediaSourceInfoCopyWithImpl;
@override @useResult
$Res call({
 String id, String? container, int? runTimeTicks, bool supportsDirectPlay, bool supportsDirectStream, bool supportsTranscoding, String? transcodingUrl, List<MediaStream> mediaStreams, int? defaultAudioStreamIndex, int? defaultSubtitleStreamIndex
});




}
/// @nodoc
class __$MediaSourceInfoCopyWithImpl<$Res>
    implements _$MediaSourceInfoCopyWith<$Res> {
  __$MediaSourceInfoCopyWithImpl(this._self, this._then);

  final _MediaSourceInfo _self;
  final $Res Function(_MediaSourceInfo) _then;

/// Create a copy of MediaSourceInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? container = freezed,Object? runTimeTicks = freezed,Object? supportsDirectPlay = null,Object? supportsDirectStream = null,Object? supportsTranscoding = null,Object? transcodingUrl = freezed,Object? mediaStreams = null,Object? defaultAudioStreamIndex = freezed,Object? defaultSubtitleStreamIndex = freezed,}) {
  return _then(_MediaSourceInfo(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,container: freezed == container ? _self.container : container // ignore: cast_nullable_to_non_nullable
as String?,runTimeTicks: freezed == runTimeTicks ? _self.runTimeTicks : runTimeTicks // ignore: cast_nullable_to_non_nullable
as int?,supportsDirectPlay: null == supportsDirectPlay ? _self.supportsDirectPlay : supportsDirectPlay // ignore: cast_nullable_to_non_nullable
as bool,supportsDirectStream: null == supportsDirectStream ? _self.supportsDirectStream : supportsDirectStream // ignore: cast_nullable_to_non_nullable
as bool,supportsTranscoding: null == supportsTranscoding ? _self.supportsTranscoding : supportsTranscoding // ignore: cast_nullable_to_non_nullable
as bool,transcodingUrl: freezed == transcodingUrl ? _self.transcodingUrl : transcodingUrl // ignore: cast_nullable_to_non_nullable
as String?,mediaStreams: null == mediaStreams ? _self.mediaStreams : mediaStreams // ignore: cast_nullable_to_non_nullable
as List<MediaStream>,defaultAudioStreamIndex: freezed == defaultAudioStreamIndex ? _self.defaultAudioStreamIndex : defaultAudioStreamIndex // ignore: cast_nullable_to_non_nullable
as int?,defaultSubtitleStreamIndex: freezed == defaultSubtitleStreamIndex ? _self.defaultSubtitleStreamIndex : defaultSubtitleStreamIndex // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
