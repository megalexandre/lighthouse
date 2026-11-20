// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'playback_report.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PlaybackProgressInfo {

 String get itemId; String get mediaSourceId; String? get playSessionId; int get positionTicks; bool get isPaused; bool get isMuted; bool get canSeek; PlayMethod get playMethod; int? get audioStreamIndex; int? get subtitleStreamIndex;/// 0–100.
 int? get volumeLevel;
/// Create a copy of PlaybackProgressInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackProgressInfoCopyWith<PlaybackProgressInfo> get copyWith => _$PlaybackProgressInfoCopyWithImpl<PlaybackProgressInfo>(this as PlaybackProgressInfo, _$identity);

  /// Serializes this PlaybackProgressInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackProgressInfo&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.mediaSourceId, mediaSourceId) || other.mediaSourceId == mediaSourceId)&&(identical(other.playSessionId, playSessionId) || other.playSessionId == playSessionId)&&(identical(other.positionTicks, positionTicks) || other.positionTicks == positionTicks)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.canSeek, canSeek) || other.canSeek == canSeek)&&(identical(other.playMethod, playMethod) || other.playMethod == playMethod)&&(identical(other.audioStreamIndex, audioStreamIndex) || other.audioStreamIndex == audioStreamIndex)&&(identical(other.subtitleStreamIndex, subtitleStreamIndex) || other.subtitleStreamIndex == subtitleStreamIndex)&&(identical(other.volumeLevel, volumeLevel) || other.volumeLevel == volumeLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,mediaSourceId,playSessionId,positionTicks,isPaused,isMuted,canSeek,playMethod,audioStreamIndex,subtitleStreamIndex,volumeLevel);

@override
String toString() {
  return 'PlaybackProgressInfo(itemId: $itemId, mediaSourceId: $mediaSourceId, playSessionId: $playSessionId, positionTicks: $positionTicks, isPaused: $isPaused, isMuted: $isMuted, canSeek: $canSeek, playMethod: $playMethod, audioStreamIndex: $audioStreamIndex, subtitleStreamIndex: $subtitleStreamIndex, volumeLevel: $volumeLevel)';
}


}

/// @nodoc
abstract mixin class $PlaybackProgressInfoCopyWith<$Res>  {
  factory $PlaybackProgressInfoCopyWith(PlaybackProgressInfo value, $Res Function(PlaybackProgressInfo) _then) = _$PlaybackProgressInfoCopyWithImpl;
@useResult
$Res call({
 String itemId, String mediaSourceId, String? playSessionId, int positionTicks, bool isPaused, bool isMuted, bool canSeek, PlayMethod playMethod, int? audioStreamIndex, int? subtitleStreamIndex, int? volumeLevel
});




}
/// @nodoc
class _$PlaybackProgressInfoCopyWithImpl<$Res>
    implements $PlaybackProgressInfoCopyWith<$Res> {
  _$PlaybackProgressInfoCopyWithImpl(this._self, this._then);

  final PlaybackProgressInfo _self;
  final $Res Function(PlaybackProgressInfo) _then;

/// Create a copy of PlaybackProgressInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemId = null,Object? mediaSourceId = null,Object? playSessionId = freezed,Object? positionTicks = null,Object? isPaused = null,Object? isMuted = null,Object? canSeek = null,Object? playMethod = null,Object? audioStreamIndex = freezed,Object? subtitleStreamIndex = freezed,Object? volumeLevel = freezed,}) {
  return _then(_self.copyWith(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,mediaSourceId: null == mediaSourceId ? _self.mediaSourceId : mediaSourceId // ignore: cast_nullable_to_non_nullable
as String,playSessionId: freezed == playSessionId ? _self.playSessionId : playSessionId // ignore: cast_nullable_to_non_nullable
as String?,positionTicks: null == positionTicks ? _self.positionTicks : positionTicks // ignore: cast_nullable_to_non_nullable
as int,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,canSeek: null == canSeek ? _self.canSeek : canSeek // ignore: cast_nullable_to_non_nullable
as bool,playMethod: null == playMethod ? _self.playMethod : playMethod // ignore: cast_nullable_to_non_nullable
as PlayMethod,audioStreamIndex: freezed == audioStreamIndex ? _self.audioStreamIndex : audioStreamIndex // ignore: cast_nullable_to_non_nullable
as int?,subtitleStreamIndex: freezed == subtitleStreamIndex ? _self.subtitleStreamIndex : subtitleStreamIndex // ignore: cast_nullable_to_non_nullable
as int?,volumeLevel: freezed == volumeLevel ? _self.volumeLevel : volumeLevel // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackProgressInfo].
extension PlaybackProgressInfoPatterns on PlaybackProgressInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackProgressInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackProgressInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackProgressInfo value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackProgressInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackProgressInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackProgressInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String itemId,  String mediaSourceId,  String? playSessionId,  int positionTicks,  bool isPaused,  bool isMuted,  bool canSeek,  PlayMethod playMethod,  int? audioStreamIndex,  int? subtitleStreamIndex,  int? volumeLevel)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackProgressInfo() when $default != null:
return $default(_that.itemId,_that.mediaSourceId,_that.playSessionId,_that.positionTicks,_that.isPaused,_that.isMuted,_that.canSeek,_that.playMethod,_that.audioStreamIndex,_that.subtitleStreamIndex,_that.volumeLevel);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String itemId,  String mediaSourceId,  String? playSessionId,  int positionTicks,  bool isPaused,  bool isMuted,  bool canSeek,  PlayMethod playMethod,  int? audioStreamIndex,  int? subtitleStreamIndex,  int? volumeLevel)  $default,) {final _that = this;
switch (_that) {
case _PlaybackProgressInfo():
return $default(_that.itemId,_that.mediaSourceId,_that.playSessionId,_that.positionTicks,_that.isPaused,_that.isMuted,_that.canSeek,_that.playMethod,_that.audioStreamIndex,_that.subtitleStreamIndex,_that.volumeLevel);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String itemId,  String mediaSourceId,  String? playSessionId,  int positionTicks,  bool isPaused,  bool isMuted,  bool canSeek,  PlayMethod playMethod,  int? audioStreamIndex,  int? subtitleStreamIndex,  int? volumeLevel)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackProgressInfo() when $default != null:
return $default(_that.itemId,_that.mediaSourceId,_that.playSessionId,_that.positionTicks,_that.isPaused,_that.isMuted,_that.canSeek,_that.playMethod,_that.audioStreamIndex,_that.subtitleStreamIndex,_that.volumeLevel);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _PlaybackProgressInfo implements PlaybackProgressInfo {
  const _PlaybackProgressInfo({required this.itemId, required this.mediaSourceId, this.playSessionId, required this.positionTicks, this.isPaused = false, this.isMuted = false, this.canSeek = true, required this.playMethod, this.audioStreamIndex, this.subtitleStreamIndex, this.volumeLevel});
  

@override final  String itemId;
@override final  String mediaSourceId;
@override final  String? playSessionId;
@override final  int positionTicks;
@override@JsonKey() final  bool isPaused;
@override@JsonKey() final  bool isMuted;
@override@JsonKey() final  bool canSeek;
@override final  PlayMethod playMethod;
@override final  int? audioStreamIndex;
@override final  int? subtitleStreamIndex;
/// 0–100.
@override final  int? volumeLevel;

/// Create a copy of PlaybackProgressInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackProgressInfoCopyWith<_PlaybackProgressInfo> get copyWith => __$PlaybackProgressInfoCopyWithImpl<_PlaybackProgressInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaybackProgressInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackProgressInfo&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.mediaSourceId, mediaSourceId) || other.mediaSourceId == mediaSourceId)&&(identical(other.playSessionId, playSessionId) || other.playSessionId == playSessionId)&&(identical(other.positionTicks, positionTicks) || other.positionTicks == positionTicks)&&(identical(other.isPaused, isPaused) || other.isPaused == isPaused)&&(identical(other.isMuted, isMuted) || other.isMuted == isMuted)&&(identical(other.canSeek, canSeek) || other.canSeek == canSeek)&&(identical(other.playMethod, playMethod) || other.playMethod == playMethod)&&(identical(other.audioStreamIndex, audioStreamIndex) || other.audioStreamIndex == audioStreamIndex)&&(identical(other.subtitleStreamIndex, subtitleStreamIndex) || other.subtitleStreamIndex == subtitleStreamIndex)&&(identical(other.volumeLevel, volumeLevel) || other.volumeLevel == volumeLevel));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,mediaSourceId,playSessionId,positionTicks,isPaused,isMuted,canSeek,playMethod,audioStreamIndex,subtitleStreamIndex,volumeLevel);

@override
String toString() {
  return 'PlaybackProgressInfo(itemId: $itemId, mediaSourceId: $mediaSourceId, playSessionId: $playSessionId, positionTicks: $positionTicks, isPaused: $isPaused, isMuted: $isMuted, canSeek: $canSeek, playMethod: $playMethod, audioStreamIndex: $audioStreamIndex, subtitleStreamIndex: $subtitleStreamIndex, volumeLevel: $volumeLevel)';
}


}

/// @nodoc
abstract mixin class _$PlaybackProgressInfoCopyWith<$Res> implements $PlaybackProgressInfoCopyWith<$Res> {
  factory _$PlaybackProgressInfoCopyWith(_PlaybackProgressInfo value, $Res Function(_PlaybackProgressInfo) _then) = __$PlaybackProgressInfoCopyWithImpl;
@override @useResult
$Res call({
 String itemId, String mediaSourceId, String? playSessionId, int positionTicks, bool isPaused, bool isMuted, bool canSeek, PlayMethod playMethod, int? audioStreamIndex, int? subtitleStreamIndex, int? volumeLevel
});




}
/// @nodoc
class __$PlaybackProgressInfoCopyWithImpl<$Res>
    implements _$PlaybackProgressInfoCopyWith<$Res> {
  __$PlaybackProgressInfoCopyWithImpl(this._self, this._then);

  final _PlaybackProgressInfo _self;
  final $Res Function(_PlaybackProgressInfo) _then;

/// Create a copy of PlaybackProgressInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = null,Object? mediaSourceId = null,Object? playSessionId = freezed,Object? positionTicks = null,Object? isPaused = null,Object? isMuted = null,Object? canSeek = null,Object? playMethod = null,Object? audioStreamIndex = freezed,Object? subtitleStreamIndex = freezed,Object? volumeLevel = freezed,}) {
  return _then(_PlaybackProgressInfo(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,mediaSourceId: null == mediaSourceId ? _self.mediaSourceId : mediaSourceId // ignore: cast_nullable_to_non_nullable
as String,playSessionId: freezed == playSessionId ? _self.playSessionId : playSessionId // ignore: cast_nullable_to_non_nullable
as String?,positionTicks: null == positionTicks ? _self.positionTicks : positionTicks // ignore: cast_nullable_to_non_nullable
as int,isPaused: null == isPaused ? _self.isPaused : isPaused // ignore: cast_nullable_to_non_nullable
as bool,isMuted: null == isMuted ? _self.isMuted : isMuted // ignore: cast_nullable_to_non_nullable
as bool,canSeek: null == canSeek ? _self.canSeek : canSeek // ignore: cast_nullable_to_non_nullable
as bool,playMethod: null == playMethod ? _self.playMethod : playMethod // ignore: cast_nullable_to_non_nullable
as PlayMethod,audioStreamIndex: freezed == audioStreamIndex ? _self.audioStreamIndex : audioStreamIndex // ignore: cast_nullable_to_non_nullable
as int?,subtitleStreamIndex: freezed == subtitleStreamIndex ? _self.subtitleStreamIndex : subtitleStreamIndex // ignore: cast_nullable_to_non_nullable
as int?,volumeLevel: freezed == volumeLevel ? _self.volumeLevel : volumeLevel // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

/// @nodoc
mixin _$PlaybackStopInfo {

 String get itemId; String get mediaSourceId; String? get playSessionId; int get positionTicks; bool get failed;
/// Create a copy of PlaybackStopInfo
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PlaybackStopInfoCopyWith<PlaybackStopInfo> get copyWith => _$PlaybackStopInfoCopyWithImpl<PlaybackStopInfo>(this as PlaybackStopInfo, _$identity);

  /// Serializes this PlaybackStopInfo to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PlaybackStopInfo&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.mediaSourceId, mediaSourceId) || other.mediaSourceId == mediaSourceId)&&(identical(other.playSessionId, playSessionId) || other.playSessionId == playSessionId)&&(identical(other.positionTicks, positionTicks) || other.positionTicks == positionTicks)&&(identical(other.failed, failed) || other.failed == failed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,mediaSourceId,playSessionId,positionTicks,failed);

@override
String toString() {
  return 'PlaybackStopInfo(itemId: $itemId, mediaSourceId: $mediaSourceId, playSessionId: $playSessionId, positionTicks: $positionTicks, failed: $failed)';
}


}

/// @nodoc
abstract mixin class $PlaybackStopInfoCopyWith<$Res>  {
  factory $PlaybackStopInfoCopyWith(PlaybackStopInfo value, $Res Function(PlaybackStopInfo) _then) = _$PlaybackStopInfoCopyWithImpl;
@useResult
$Res call({
 String itemId, String mediaSourceId, String? playSessionId, int positionTicks, bool failed
});




}
/// @nodoc
class _$PlaybackStopInfoCopyWithImpl<$Res>
    implements $PlaybackStopInfoCopyWith<$Res> {
  _$PlaybackStopInfoCopyWithImpl(this._self, this._then);

  final PlaybackStopInfo _self;
  final $Res Function(PlaybackStopInfo) _then;

/// Create a copy of PlaybackStopInfo
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? itemId = null,Object? mediaSourceId = null,Object? playSessionId = freezed,Object? positionTicks = null,Object? failed = null,}) {
  return _then(_self.copyWith(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,mediaSourceId: null == mediaSourceId ? _self.mediaSourceId : mediaSourceId // ignore: cast_nullable_to_non_nullable
as String,playSessionId: freezed == playSessionId ? _self.playSessionId : playSessionId // ignore: cast_nullable_to_non_nullable
as String?,positionTicks: null == positionTicks ? _self.positionTicks : positionTicks // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PlaybackStopInfo].
extension PlaybackStopInfoPatterns on PlaybackStopInfo {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PlaybackStopInfo value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PlaybackStopInfo() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PlaybackStopInfo value)  $default,){
final _that = this;
switch (_that) {
case _PlaybackStopInfo():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PlaybackStopInfo value)?  $default,){
final _that = this;
switch (_that) {
case _PlaybackStopInfo() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String itemId,  String mediaSourceId,  String? playSessionId,  int positionTicks,  bool failed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PlaybackStopInfo() when $default != null:
return $default(_that.itemId,_that.mediaSourceId,_that.playSessionId,_that.positionTicks,_that.failed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String itemId,  String mediaSourceId,  String? playSessionId,  int positionTicks,  bool failed)  $default,) {final _that = this;
switch (_that) {
case _PlaybackStopInfo():
return $default(_that.itemId,_that.mediaSourceId,_that.playSessionId,_that.positionTicks,_that.failed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String itemId,  String mediaSourceId,  String? playSessionId,  int positionTicks,  bool failed)?  $default,) {final _that = this;
switch (_that) {
case _PlaybackStopInfo() when $default != null:
return $default(_that.itemId,_that.mediaSourceId,_that.playSessionId,_that.positionTicks,_that.failed);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable(createFactory: false)

class _PlaybackStopInfo implements PlaybackStopInfo {
  const _PlaybackStopInfo({required this.itemId, required this.mediaSourceId, this.playSessionId, required this.positionTicks, this.failed = false});
  

@override final  String itemId;
@override final  String mediaSourceId;
@override final  String? playSessionId;
@override final  int positionTicks;
@override@JsonKey() final  bool failed;

/// Create a copy of PlaybackStopInfo
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PlaybackStopInfoCopyWith<_PlaybackStopInfo> get copyWith => __$PlaybackStopInfoCopyWithImpl<_PlaybackStopInfo>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PlaybackStopInfoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PlaybackStopInfo&&(identical(other.itemId, itemId) || other.itemId == itemId)&&(identical(other.mediaSourceId, mediaSourceId) || other.mediaSourceId == mediaSourceId)&&(identical(other.playSessionId, playSessionId) || other.playSessionId == playSessionId)&&(identical(other.positionTicks, positionTicks) || other.positionTicks == positionTicks)&&(identical(other.failed, failed) || other.failed == failed));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,itemId,mediaSourceId,playSessionId,positionTicks,failed);

@override
String toString() {
  return 'PlaybackStopInfo(itemId: $itemId, mediaSourceId: $mediaSourceId, playSessionId: $playSessionId, positionTicks: $positionTicks, failed: $failed)';
}


}

/// @nodoc
abstract mixin class _$PlaybackStopInfoCopyWith<$Res> implements $PlaybackStopInfoCopyWith<$Res> {
  factory _$PlaybackStopInfoCopyWith(_PlaybackStopInfo value, $Res Function(_PlaybackStopInfo) _then) = __$PlaybackStopInfoCopyWithImpl;
@override @useResult
$Res call({
 String itemId, String mediaSourceId, String? playSessionId, int positionTicks, bool failed
});




}
/// @nodoc
class __$PlaybackStopInfoCopyWithImpl<$Res>
    implements _$PlaybackStopInfoCopyWith<$Res> {
  __$PlaybackStopInfoCopyWithImpl(this._self, this._then);

  final _PlaybackStopInfo _self;
  final $Res Function(_PlaybackStopInfo) _then;

/// Create a copy of PlaybackStopInfo
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? itemId = null,Object? mediaSourceId = null,Object? playSessionId = freezed,Object? positionTicks = null,Object? failed = null,}) {
  return _then(_PlaybackStopInfo(
itemId: null == itemId ? _self.itemId : itemId // ignore: cast_nullable_to_non_nullable
as String,mediaSourceId: null == mediaSourceId ? _self.mediaSourceId : mediaSourceId // ignore: cast_nullable_to_non_nullable
as String,playSessionId: freezed == playSessionId ? _self.playSessionId : playSessionId // ignore: cast_nullable_to_non_nullable
as String?,positionTicks: null == positionTicks ? _self.positionTicks : positionTicks // ignore: cast_nullable_to_non_nullable
as int,failed: null == failed ? _self.failed : failed // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
