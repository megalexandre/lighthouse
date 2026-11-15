// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'base_item_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BaseItemDto {

 String get id; String get name;@JsonKey(unknownEnumValue: BaseItemKind.unknown) BaseItemKind get type;/// For libraries: movies, tvshows, music, boxsets...
 String? get collectionType; String? get overview; int? get productionYear; String? get officialRating;/// Length in ticks (see core/ticks.dart).
 int? get runTimeTicks;/// Episode / track number, and the season / disc it belongs to.
 int? get indexNumber; int? get parentIndexNumber; String? get seriesId; String? get seriesName; String? get seasonId; String? get seasonName; String? get seriesPrimaryImageTag; String? get albumArtist;/// Image type (Primary, Thumb, Logo...) → tag, which changes when the
/// image does; it goes in the image URL so caches stay right.
 Map<String, String> get imageTags; List<String> get backdropImageTags; UserItemDataDto? get userData; int? get childCount;
/// Create a copy of BaseItemDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BaseItemDtoCopyWith<BaseItemDto> get copyWith => _$BaseItemDtoCopyWithImpl<BaseItemDto>(this as BaseItemDto, _$identity);

  /// Serializes this BaseItemDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BaseItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.collectionType, collectionType) || other.collectionType == collectionType)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.productionYear, productionYear) || other.productionYear == productionYear)&&(identical(other.officialRating, officialRating) || other.officialRating == officialRating)&&(identical(other.runTimeTicks, runTimeTicks) || other.runTimeTicks == runTimeTicks)&&(identical(other.indexNumber, indexNumber) || other.indexNumber == indexNumber)&&(identical(other.parentIndexNumber, parentIndexNumber) || other.parentIndexNumber == parentIndexNumber)&&(identical(other.seriesId, seriesId) || other.seriesId == seriesId)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.seasonName, seasonName) || other.seasonName == seasonName)&&(identical(other.seriesPrimaryImageTag, seriesPrimaryImageTag) || other.seriesPrimaryImageTag == seriesPrimaryImageTag)&&(identical(other.albumArtist, albumArtist) || other.albumArtist == albumArtist)&&const DeepCollectionEquality().equals(other.imageTags, imageTags)&&const DeepCollectionEquality().equals(other.backdropImageTags, backdropImageTags)&&(identical(other.userData, userData) || other.userData == userData)&&(identical(other.childCount, childCount) || other.childCount == childCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,collectionType,overview,productionYear,officialRating,runTimeTicks,indexNumber,parentIndexNumber,seriesId,seriesName,seasonId,seasonName,seriesPrimaryImageTag,albumArtist,const DeepCollectionEquality().hash(imageTags),const DeepCollectionEquality().hash(backdropImageTags),userData,childCount]);

@override
String toString() {
  return 'BaseItemDto(id: $id, name: $name, type: $type, collectionType: $collectionType, overview: $overview, productionYear: $productionYear, officialRating: $officialRating, runTimeTicks: $runTimeTicks, indexNumber: $indexNumber, parentIndexNumber: $parentIndexNumber, seriesId: $seriesId, seriesName: $seriesName, seasonId: $seasonId, seasonName: $seasonName, seriesPrimaryImageTag: $seriesPrimaryImageTag, albumArtist: $albumArtist, imageTags: $imageTags, backdropImageTags: $backdropImageTags, userData: $userData, childCount: $childCount)';
}


}

/// @nodoc
abstract mixin class $BaseItemDtoCopyWith<$Res>  {
  factory $BaseItemDtoCopyWith(BaseItemDto value, $Res Function(BaseItemDto) _then) = _$BaseItemDtoCopyWithImpl;
@useResult
$Res call({
 String id, String name,@JsonKey(unknownEnumValue: BaseItemKind.unknown) BaseItemKind type, String? collectionType, String? overview, int? productionYear, String? officialRating, int? runTimeTicks, int? indexNumber, int? parentIndexNumber, String? seriesId, String? seriesName, String? seasonId, String? seasonName, String? seriesPrimaryImageTag, String? albumArtist, Map<String, String> imageTags, List<String> backdropImageTags, UserItemDataDto? userData, int? childCount
});


$UserItemDataDtoCopyWith<$Res>? get userData;

}
/// @nodoc
class _$BaseItemDtoCopyWithImpl<$Res>
    implements $BaseItemDtoCopyWith<$Res> {
  _$BaseItemDtoCopyWithImpl(this._self, this._then);

  final BaseItemDto _self;
  final $Res Function(BaseItemDto) _then;

/// Create a copy of BaseItemDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? collectionType = freezed,Object? overview = freezed,Object? productionYear = freezed,Object? officialRating = freezed,Object? runTimeTicks = freezed,Object? indexNumber = freezed,Object? parentIndexNumber = freezed,Object? seriesId = freezed,Object? seriesName = freezed,Object? seasonId = freezed,Object? seasonName = freezed,Object? seriesPrimaryImageTag = freezed,Object? albumArtist = freezed,Object? imageTags = null,Object? backdropImageTags = null,Object? userData = freezed,Object? childCount = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BaseItemKind,collectionType: freezed == collectionType ? _self.collectionType : collectionType // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,productionYear: freezed == productionYear ? _self.productionYear : productionYear // ignore: cast_nullable_to_non_nullable
as int?,officialRating: freezed == officialRating ? _self.officialRating : officialRating // ignore: cast_nullable_to_non_nullable
as String?,runTimeTicks: freezed == runTimeTicks ? _self.runTimeTicks : runTimeTicks // ignore: cast_nullable_to_non_nullable
as int?,indexNumber: freezed == indexNumber ? _self.indexNumber : indexNumber // ignore: cast_nullable_to_non_nullable
as int?,parentIndexNumber: freezed == parentIndexNumber ? _self.parentIndexNumber : parentIndexNumber // ignore: cast_nullable_to_non_nullable
as int?,seriesId: freezed == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as String?,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,seasonId: freezed == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as String?,seasonName: freezed == seasonName ? _self.seasonName : seasonName // ignore: cast_nullable_to_non_nullable
as String?,seriesPrimaryImageTag: freezed == seriesPrimaryImageTag ? _self.seriesPrimaryImageTag : seriesPrimaryImageTag // ignore: cast_nullable_to_non_nullable
as String?,albumArtist: freezed == albumArtist ? _self.albumArtist : albumArtist // ignore: cast_nullable_to_non_nullable
as String?,imageTags: null == imageTags ? _self.imageTags : imageTags // ignore: cast_nullable_to_non_nullable
as Map<String, String>,backdropImageTags: null == backdropImageTags ? _self.backdropImageTags : backdropImageTags // ignore: cast_nullable_to_non_nullable
as List<String>,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as UserItemDataDto?,childCount: freezed == childCount ? _self.childCount : childCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}
/// Create a copy of BaseItemDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserItemDataDtoCopyWith<$Res>? get userData {
    if (_self.userData == null) {
    return null;
  }

  return $UserItemDataDtoCopyWith<$Res>(_self.userData!, (value) {
    return _then(_self.copyWith(userData: value));
  });
}
}


/// Adds pattern-matching-related methods to [BaseItemDto].
extension BaseItemDtoPatterns on BaseItemDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BaseItemDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BaseItemDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BaseItemDto value)  $default,){
final _that = this;
switch (_that) {
case _BaseItemDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BaseItemDto value)?  $default,){
final _that = this;
switch (_that) {
case _BaseItemDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(unknownEnumValue: BaseItemKind.unknown)  BaseItemKind type,  String? collectionType,  String? overview,  int? productionYear,  String? officialRating,  int? runTimeTicks,  int? indexNumber,  int? parentIndexNumber,  String? seriesId,  String? seriesName,  String? seasonId,  String? seasonName,  String? seriesPrimaryImageTag,  String? albumArtist,  Map<String, String> imageTags,  List<String> backdropImageTags,  UserItemDataDto? userData,  int? childCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BaseItemDto() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.collectionType,_that.overview,_that.productionYear,_that.officialRating,_that.runTimeTicks,_that.indexNumber,_that.parentIndexNumber,_that.seriesId,_that.seriesName,_that.seasonId,_that.seasonName,_that.seriesPrimaryImageTag,_that.albumArtist,_that.imageTags,_that.backdropImageTags,_that.userData,_that.childCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name, @JsonKey(unknownEnumValue: BaseItemKind.unknown)  BaseItemKind type,  String? collectionType,  String? overview,  int? productionYear,  String? officialRating,  int? runTimeTicks,  int? indexNumber,  int? parentIndexNumber,  String? seriesId,  String? seriesName,  String? seasonId,  String? seasonName,  String? seriesPrimaryImageTag,  String? albumArtist,  Map<String, String> imageTags,  List<String> backdropImageTags,  UserItemDataDto? userData,  int? childCount)  $default,) {final _that = this;
switch (_that) {
case _BaseItemDto():
return $default(_that.id,_that.name,_that.type,_that.collectionType,_that.overview,_that.productionYear,_that.officialRating,_that.runTimeTicks,_that.indexNumber,_that.parentIndexNumber,_that.seriesId,_that.seriesName,_that.seasonId,_that.seasonName,_that.seriesPrimaryImageTag,_that.albumArtist,_that.imageTags,_that.backdropImageTags,_that.userData,_that.childCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name, @JsonKey(unknownEnumValue: BaseItemKind.unknown)  BaseItemKind type,  String? collectionType,  String? overview,  int? productionYear,  String? officialRating,  int? runTimeTicks,  int? indexNumber,  int? parentIndexNumber,  String? seriesId,  String? seriesName,  String? seasonId,  String? seasonName,  String? seriesPrimaryImageTag,  String? albumArtist,  Map<String, String> imageTags,  List<String> backdropImageTags,  UserItemDataDto? userData,  int? childCount)?  $default,) {final _that = this;
switch (_that) {
case _BaseItemDto() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.collectionType,_that.overview,_that.productionYear,_that.officialRating,_that.runTimeTicks,_that.indexNumber,_that.parentIndexNumber,_that.seriesId,_that.seriesName,_that.seasonId,_that.seasonName,_that.seriesPrimaryImageTag,_that.albumArtist,_that.imageTags,_that.backdropImageTags,_that.userData,_that.childCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BaseItemDto extends BaseItemDto {
  const _BaseItemDto({required this.id, required this.name, @JsonKey(unknownEnumValue: BaseItemKind.unknown) required this.type, this.collectionType, this.overview, this.productionYear, this.officialRating, this.runTimeTicks, this.indexNumber, this.parentIndexNumber, this.seriesId, this.seriesName, this.seasonId, this.seasonName, this.seriesPrimaryImageTag, this.albumArtist, this.imageTags = const {}, this.backdropImageTags = const [], this.userData, this.childCount}): super._();
  factory _BaseItemDto.fromJson(Map<String, dynamic> json) => _$BaseItemDtoFromJson(json);

@override final  String id;
@override final  String name;
@override@JsonKey(unknownEnumValue: BaseItemKind.unknown) final  BaseItemKind type;
/// For libraries: movies, tvshows, music, boxsets...
@override final  String? collectionType;
@override final  String? overview;
@override final  int? productionYear;
@override final  String? officialRating;
/// Length in ticks (see core/ticks.dart).
@override final  int? runTimeTicks;
/// Episode / track number, and the season / disc it belongs to.
@override final  int? indexNumber;
@override final  int? parentIndexNumber;
@override final  String? seriesId;
@override final  String? seriesName;
@override final  String? seasonId;
@override final  String? seasonName;
@override final  String? seriesPrimaryImageTag;
@override final  String? albumArtist;
/// Image type (Primary, Thumb, Logo...) → tag, which changes when the
/// image does; it goes in the image URL so caches stay right.
@override@JsonKey() final  Map<String, String> imageTags;
@override@JsonKey() final  List<String> backdropImageTags;
@override final  UserItemDataDto? userData;
@override final  int? childCount;

/// Create a copy of BaseItemDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BaseItemDtoCopyWith<_BaseItemDto> get copyWith => __$BaseItemDtoCopyWithImpl<_BaseItemDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BaseItemDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BaseItemDto&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.collectionType, collectionType) || other.collectionType == collectionType)&&(identical(other.overview, overview) || other.overview == overview)&&(identical(other.productionYear, productionYear) || other.productionYear == productionYear)&&(identical(other.officialRating, officialRating) || other.officialRating == officialRating)&&(identical(other.runTimeTicks, runTimeTicks) || other.runTimeTicks == runTimeTicks)&&(identical(other.indexNumber, indexNumber) || other.indexNumber == indexNumber)&&(identical(other.parentIndexNumber, parentIndexNumber) || other.parentIndexNumber == parentIndexNumber)&&(identical(other.seriesId, seriesId) || other.seriesId == seriesId)&&(identical(other.seriesName, seriesName) || other.seriesName == seriesName)&&(identical(other.seasonId, seasonId) || other.seasonId == seasonId)&&(identical(other.seasonName, seasonName) || other.seasonName == seasonName)&&(identical(other.seriesPrimaryImageTag, seriesPrimaryImageTag) || other.seriesPrimaryImageTag == seriesPrimaryImageTag)&&(identical(other.albumArtist, albumArtist) || other.albumArtist == albumArtist)&&const DeepCollectionEquality().equals(other.imageTags, imageTags)&&const DeepCollectionEquality().equals(other.backdropImageTags, backdropImageTags)&&(identical(other.userData, userData) || other.userData == userData)&&(identical(other.childCount, childCount) || other.childCount == childCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,type,collectionType,overview,productionYear,officialRating,runTimeTicks,indexNumber,parentIndexNumber,seriesId,seriesName,seasonId,seasonName,seriesPrimaryImageTag,albumArtist,const DeepCollectionEquality().hash(imageTags),const DeepCollectionEquality().hash(backdropImageTags),userData,childCount]);

@override
String toString() {
  return 'BaseItemDto(id: $id, name: $name, type: $type, collectionType: $collectionType, overview: $overview, productionYear: $productionYear, officialRating: $officialRating, runTimeTicks: $runTimeTicks, indexNumber: $indexNumber, parentIndexNumber: $parentIndexNumber, seriesId: $seriesId, seriesName: $seriesName, seasonId: $seasonId, seasonName: $seasonName, seriesPrimaryImageTag: $seriesPrimaryImageTag, albumArtist: $albumArtist, imageTags: $imageTags, backdropImageTags: $backdropImageTags, userData: $userData, childCount: $childCount)';
}


}

/// @nodoc
abstract mixin class _$BaseItemDtoCopyWith<$Res> implements $BaseItemDtoCopyWith<$Res> {
  factory _$BaseItemDtoCopyWith(_BaseItemDto value, $Res Function(_BaseItemDto) _then) = __$BaseItemDtoCopyWithImpl;
@override @useResult
$Res call({
 String id, String name,@JsonKey(unknownEnumValue: BaseItemKind.unknown) BaseItemKind type, String? collectionType, String? overview, int? productionYear, String? officialRating, int? runTimeTicks, int? indexNumber, int? parentIndexNumber, String? seriesId, String? seriesName, String? seasonId, String? seasonName, String? seriesPrimaryImageTag, String? albumArtist, Map<String, String> imageTags, List<String> backdropImageTags, UserItemDataDto? userData, int? childCount
});


@override $UserItemDataDtoCopyWith<$Res>? get userData;

}
/// @nodoc
class __$BaseItemDtoCopyWithImpl<$Res>
    implements _$BaseItemDtoCopyWith<$Res> {
  __$BaseItemDtoCopyWithImpl(this._self, this._then);

  final _BaseItemDto _self;
  final $Res Function(_BaseItemDto) _then;

/// Create a copy of BaseItemDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? collectionType = freezed,Object? overview = freezed,Object? productionYear = freezed,Object? officialRating = freezed,Object? runTimeTicks = freezed,Object? indexNumber = freezed,Object? parentIndexNumber = freezed,Object? seriesId = freezed,Object? seriesName = freezed,Object? seasonId = freezed,Object? seasonName = freezed,Object? seriesPrimaryImageTag = freezed,Object? albumArtist = freezed,Object? imageTags = null,Object? backdropImageTags = null,Object? userData = freezed,Object? childCount = freezed,}) {
  return _then(_BaseItemDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as BaseItemKind,collectionType: freezed == collectionType ? _self.collectionType : collectionType // ignore: cast_nullable_to_non_nullable
as String?,overview: freezed == overview ? _self.overview : overview // ignore: cast_nullable_to_non_nullable
as String?,productionYear: freezed == productionYear ? _self.productionYear : productionYear // ignore: cast_nullable_to_non_nullable
as int?,officialRating: freezed == officialRating ? _self.officialRating : officialRating // ignore: cast_nullable_to_non_nullable
as String?,runTimeTicks: freezed == runTimeTicks ? _self.runTimeTicks : runTimeTicks // ignore: cast_nullable_to_non_nullable
as int?,indexNumber: freezed == indexNumber ? _self.indexNumber : indexNumber // ignore: cast_nullable_to_non_nullable
as int?,parentIndexNumber: freezed == parentIndexNumber ? _self.parentIndexNumber : parentIndexNumber // ignore: cast_nullable_to_non_nullable
as int?,seriesId: freezed == seriesId ? _self.seriesId : seriesId // ignore: cast_nullable_to_non_nullable
as String?,seriesName: freezed == seriesName ? _self.seriesName : seriesName // ignore: cast_nullable_to_non_nullable
as String?,seasonId: freezed == seasonId ? _self.seasonId : seasonId // ignore: cast_nullable_to_non_nullable
as String?,seasonName: freezed == seasonName ? _self.seasonName : seasonName // ignore: cast_nullable_to_non_nullable
as String?,seriesPrimaryImageTag: freezed == seriesPrimaryImageTag ? _self.seriesPrimaryImageTag : seriesPrimaryImageTag // ignore: cast_nullable_to_non_nullable
as String?,albumArtist: freezed == albumArtist ? _self.albumArtist : albumArtist // ignore: cast_nullable_to_non_nullable
as String?,imageTags: null == imageTags ? _self.imageTags : imageTags // ignore: cast_nullable_to_non_nullable
as Map<String, String>,backdropImageTags: null == backdropImageTags ? _self.backdropImageTags : backdropImageTags // ignore: cast_nullable_to_non_nullable
as List<String>,userData: freezed == userData ? _self.userData : userData // ignore: cast_nullable_to_non_nullable
as UserItemDataDto?,childCount: freezed == childCount ? _self.childCount : childCount // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

/// Create a copy of BaseItemDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UserItemDataDtoCopyWith<$Res>? get userData {
    if (_self.userData == null) {
    return null;
  }

  return $UserItemDataDtoCopyWith<$Res>(_self.userData!, (value) {
    return _then(_self.copyWith(userData: value));
  });
}
}

// dart format on
