// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'media_stream.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MediaStream {

 int get index;@JsonKey(unknownEnumValue: MediaStreamType.unknown) MediaStreamType get type; String? get codec; String? get language; String? get title;/// Ready-made label, e.g. "English - AAC - Mono - Default".
 String? get displayTitle; bool get isExternal; bool get isDefault; bool get isForced;@JsonKey(unknownEnumValue: SubtitleDeliveryMethod.unknown) SubtitleDeliveryMethod? get deliveryMethod;/// Server-relative URL of an external subtitle. It carries an access
/// token: never log it.
 String? get deliveryUrl; int? get channels;
/// Create a copy of MediaStream
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MediaStreamCopyWith<MediaStream> get copyWith => _$MediaStreamCopyWithImpl<MediaStream>(this as MediaStream, _$identity);

  /// Serializes this MediaStream to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MediaStream&&(identical(other.index, index) || other.index == index)&&(identical(other.type, type) || other.type == type)&&(identical(other.codec, codec) || other.codec == codec)&&(identical(other.language, language) || other.language == language)&&(identical(other.title, title) || other.title == title)&&(identical(other.displayTitle, displayTitle) || other.displayTitle == displayTitle)&&(identical(other.isExternal, isExternal) || other.isExternal == isExternal)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isForced, isForced) || other.isForced == isForced)&&(identical(other.deliveryMethod, deliveryMethod) || other.deliveryMethod == deliveryMethod)&&(identical(other.deliveryUrl, deliveryUrl) || other.deliveryUrl == deliveryUrl)&&(identical(other.channels, channels) || other.channels == channels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,type,codec,language,title,displayTitle,isExternal,isDefault,isForced,deliveryMethod,deliveryUrl,channels);

@override
String toString() {
  return 'MediaStream(index: $index, type: $type, codec: $codec, language: $language, title: $title, displayTitle: $displayTitle, isExternal: $isExternal, isDefault: $isDefault, isForced: $isForced, deliveryMethod: $deliveryMethod, deliveryUrl: $deliveryUrl, channels: $channels)';
}


}

/// @nodoc
abstract mixin class $MediaStreamCopyWith<$Res>  {
  factory $MediaStreamCopyWith(MediaStream value, $Res Function(MediaStream) _then) = _$MediaStreamCopyWithImpl;
@useResult
$Res call({
 int index,@JsonKey(unknownEnumValue: MediaStreamType.unknown) MediaStreamType type, String? codec, String? language, String? title, String? displayTitle, bool isExternal, bool isDefault, bool isForced,@JsonKey(unknownEnumValue: SubtitleDeliveryMethod.unknown) SubtitleDeliveryMethod? deliveryMethod, String? deliveryUrl, int? channels
});




}
/// @nodoc
class _$MediaStreamCopyWithImpl<$Res>
    implements $MediaStreamCopyWith<$Res> {
  _$MediaStreamCopyWithImpl(this._self, this._then);

  final MediaStream _self;
  final $Res Function(MediaStream) _then;

/// Create a copy of MediaStream
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? index = null,Object? type = null,Object? codec = freezed,Object? language = freezed,Object? title = freezed,Object? displayTitle = freezed,Object? isExternal = null,Object? isDefault = null,Object? isForced = null,Object? deliveryMethod = freezed,Object? deliveryUrl = freezed,Object? channels = freezed,}) {
  return _then(_self.copyWith(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MediaStreamType,codec: freezed == codec ? _self.codec : codec // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,displayTitle: freezed == displayTitle ? _self.displayTitle : displayTitle // ignore: cast_nullable_to_non_nullable
as String?,isExternal: null == isExternal ? _self.isExternal : isExternal // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isForced: null == isForced ? _self.isForced : isForced // ignore: cast_nullable_to_non_nullable
as bool,deliveryMethod: freezed == deliveryMethod ? _self.deliveryMethod : deliveryMethod // ignore: cast_nullable_to_non_nullable
as SubtitleDeliveryMethod?,deliveryUrl: freezed == deliveryUrl ? _self.deliveryUrl : deliveryUrl // ignore: cast_nullable_to_non_nullable
as String?,channels: freezed == channels ? _self.channels : channels // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [MediaStream].
extension MediaStreamPatterns on MediaStream {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MediaStream value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MediaStream() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MediaStream value)  $default,){
final _that = this;
switch (_that) {
case _MediaStream():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MediaStream value)?  $default,){
final _that = this;
switch (_that) {
case _MediaStream() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int index, @JsonKey(unknownEnumValue: MediaStreamType.unknown)  MediaStreamType type,  String? codec,  String? language,  String? title,  String? displayTitle,  bool isExternal,  bool isDefault,  bool isForced, @JsonKey(unknownEnumValue: SubtitleDeliveryMethod.unknown)  SubtitleDeliveryMethod? deliveryMethod,  String? deliveryUrl,  int? channels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MediaStream() when $default != null:
return $default(_that.index,_that.type,_that.codec,_that.language,_that.title,_that.displayTitle,_that.isExternal,_that.isDefault,_that.isForced,_that.deliveryMethod,_that.deliveryUrl,_that.channels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int index, @JsonKey(unknownEnumValue: MediaStreamType.unknown)  MediaStreamType type,  String? codec,  String? language,  String? title,  String? displayTitle,  bool isExternal,  bool isDefault,  bool isForced, @JsonKey(unknownEnumValue: SubtitleDeliveryMethod.unknown)  SubtitleDeliveryMethod? deliveryMethod,  String? deliveryUrl,  int? channels)  $default,) {final _that = this;
switch (_that) {
case _MediaStream():
return $default(_that.index,_that.type,_that.codec,_that.language,_that.title,_that.displayTitle,_that.isExternal,_that.isDefault,_that.isForced,_that.deliveryMethod,_that.deliveryUrl,_that.channels);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int index, @JsonKey(unknownEnumValue: MediaStreamType.unknown)  MediaStreamType type,  String? codec,  String? language,  String? title,  String? displayTitle,  bool isExternal,  bool isDefault,  bool isForced, @JsonKey(unknownEnumValue: SubtitleDeliveryMethod.unknown)  SubtitleDeliveryMethod? deliveryMethod,  String? deliveryUrl,  int? channels)?  $default,) {final _that = this;
switch (_that) {
case _MediaStream() when $default != null:
return $default(_that.index,_that.type,_that.codec,_that.language,_that.title,_that.displayTitle,_that.isExternal,_that.isDefault,_that.isForced,_that.deliveryMethod,_that.deliveryUrl,_that.channels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MediaStream implements MediaStream {
  const _MediaStream({required this.index, @JsonKey(unknownEnumValue: MediaStreamType.unknown) required this.type, this.codec, this.language, this.title, this.displayTitle, this.isExternal = false, this.isDefault = false, this.isForced = false, @JsonKey(unknownEnumValue: SubtitleDeliveryMethod.unknown) this.deliveryMethod, this.deliveryUrl, this.channels});
  factory _MediaStream.fromJson(Map<String, dynamic> json) => _$MediaStreamFromJson(json);

@override final  int index;
@override@JsonKey(unknownEnumValue: MediaStreamType.unknown) final  MediaStreamType type;
@override final  String? codec;
@override final  String? language;
@override final  String? title;
/// Ready-made label, e.g. "English - AAC - Mono - Default".
@override final  String? displayTitle;
@override@JsonKey() final  bool isExternal;
@override@JsonKey() final  bool isDefault;
@override@JsonKey() final  bool isForced;
@override@JsonKey(unknownEnumValue: SubtitleDeliveryMethod.unknown) final  SubtitleDeliveryMethod? deliveryMethod;
/// Server-relative URL of an external subtitle. It carries an access
/// token: never log it.
@override final  String? deliveryUrl;
@override final  int? channels;

/// Create a copy of MediaStream
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MediaStreamCopyWith<_MediaStream> get copyWith => __$MediaStreamCopyWithImpl<_MediaStream>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MediaStreamToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MediaStream&&(identical(other.index, index) || other.index == index)&&(identical(other.type, type) || other.type == type)&&(identical(other.codec, codec) || other.codec == codec)&&(identical(other.language, language) || other.language == language)&&(identical(other.title, title) || other.title == title)&&(identical(other.displayTitle, displayTitle) || other.displayTitle == displayTitle)&&(identical(other.isExternal, isExternal) || other.isExternal == isExternal)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.isForced, isForced) || other.isForced == isForced)&&(identical(other.deliveryMethod, deliveryMethod) || other.deliveryMethod == deliveryMethod)&&(identical(other.deliveryUrl, deliveryUrl) || other.deliveryUrl == deliveryUrl)&&(identical(other.channels, channels) || other.channels == channels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,index,type,codec,language,title,displayTitle,isExternal,isDefault,isForced,deliveryMethod,deliveryUrl,channels);

@override
String toString() {
  return 'MediaStream(index: $index, type: $type, codec: $codec, language: $language, title: $title, displayTitle: $displayTitle, isExternal: $isExternal, isDefault: $isDefault, isForced: $isForced, deliveryMethod: $deliveryMethod, deliveryUrl: $deliveryUrl, channels: $channels)';
}


}

/// @nodoc
abstract mixin class _$MediaStreamCopyWith<$Res> implements $MediaStreamCopyWith<$Res> {
  factory _$MediaStreamCopyWith(_MediaStream value, $Res Function(_MediaStream) _then) = __$MediaStreamCopyWithImpl;
@override @useResult
$Res call({
 int index,@JsonKey(unknownEnumValue: MediaStreamType.unknown) MediaStreamType type, String? codec, String? language, String? title, String? displayTitle, bool isExternal, bool isDefault, bool isForced,@JsonKey(unknownEnumValue: SubtitleDeliveryMethod.unknown) SubtitleDeliveryMethod? deliveryMethod, String? deliveryUrl, int? channels
});




}
/// @nodoc
class __$MediaStreamCopyWithImpl<$Res>
    implements _$MediaStreamCopyWith<$Res> {
  __$MediaStreamCopyWithImpl(this._self, this._then);

  final _MediaStream _self;
  final $Res Function(_MediaStream) _then;

/// Create a copy of MediaStream
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? index = null,Object? type = null,Object? codec = freezed,Object? language = freezed,Object? title = freezed,Object? displayTitle = freezed,Object? isExternal = null,Object? isDefault = null,Object? isForced = null,Object? deliveryMethod = freezed,Object? deliveryUrl = freezed,Object? channels = freezed,}) {
  return _then(_MediaStream(
index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MediaStreamType,codec: freezed == codec ? _self.codec : codec // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,displayTitle: freezed == displayTitle ? _self.displayTitle : displayTitle // ignore: cast_nullable_to_non_nullable
as String?,isExternal: null == isExternal ? _self.isExternal : isExternal // ignore: cast_nullable_to_non_nullable
as bool,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,isForced: null == isForced ? _self.isForced : isForced // ignore: cast_nullable_to_non_nullable
as bool,deliveryMethod: freezed == deliveryMethod ? _self.deliveryMethod : deliveryMethod // ignore: cast_nullable_to_non_nullable
as SubtitleDeliveryMethod?,deliveryUrl: freezed == deliveryUrl ? _self.deliveryUrl : deliveryUrl // ignore: cast_nullable_to_non_nullable
as String?,channels: freezed == channels ? _self.channels : channels // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
