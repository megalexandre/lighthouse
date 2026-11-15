// Parses JSON captured from a real Jellyfin 12.4 (test/fixtures/api).
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:jellyfin_flutter/api/models/authenticate_user_by_name.dart';
import 'package:jellyfin_flutter/api/models/authentication_result.dart';
import 'package:jellyfin_flutter/api/models/base_item_dto.dart';
import 'package:jellyfin_flutter/api/models/base_item_dto_query_result.dart';
import 'package:jellyfin_flutter/api/models/public_system_info.dart';
import 'package:jellyfin_flutter/api/models/user_dto.dart';

Object? read(String name) =>
    jsonDecode(File('test/fixtures/api/$name.json').readAsStringSync());

Map<String, dynamic> fixture(String name) =>
    read(name)! as Map<String, dynamic>;

BaseItemDtoQueryResult page(String name) =>
    BaseItemDtoQueryResult.fromJson(fixture(name));

void main() {
  test('PublicSystemInfo', () {
    final info = PublicSystemInfo.fromJson(fixture('system_info_public'));
    expect(info.id, isNotEmpty);
    expect(info.version, '12.4.0');
    expect(info.productName, 'Jellyfin Server');
    expect(info.startupWizardCompleted, isTrue);
  });

  test('AuthenticationResult', () {
    final result = AuthenticationResult.fromJson(
      fixture('authenticate_by_name'),
    );
    expect(result.accessToken, '0123456789abcdef0123456789abcdef');
    expect(result.user.name, 'alice');
    expect(result.user.id, isNotEmpty);
    expect(result.serverId, result.user.serverId);
  });

  test('UserDto', () {
    final user = UserDto.fromJson(fixture('users_me'));
    expect(user.name, 'alice');
    expect(user.hasPassword, isTrue);
  });

  test('AuthenticateUserByName uses the server field names', () {
    expect(
      const AuthenticateUserByName(username: 'alice', pw: 'secret').toJson(),
      {'Username': 'alice', 'Pw': 'secret'},
    );
  });

  test('a response missing a required field does not parse', () {
    final json = fixture('users_me')..remove('Id');
    expect(() => UserDto.fromJson(json), throwsA(isA<TypeError>()));
  });

  group('items', () {
    test('user views are libraries with a collection type', () {
      final views = page('user_views');
      expect(views.items.map((v) => v.name), ['Movies', 'Music', 'Shows']);
      expect(
        views.items.map((v) => v.type),
        everyElement(BaseItemKind.collectionFolder),
      );
      expect(views.items.map((v) => v.collectionType), [
        'movies',
        'music',
        'tvshows',
      ]);
      expect(views.items.first.type.isFolder, isTrue);
    });

    test('a page of movies', () {
      final movies = page('items_page');
      expect(movies.totalRecordCount, 2);
      expect(movies.startIndex, 0);
      final movie = movies.items.single;
      expect(movie.type, BaseItemKind.movie);
      expect(movie.productionYear, 2021);
      expect(movie.runTimeTicks, 50230000);
      expect(movie.userData!.played, isFalse);
      expect(movie.userData!.playbackPositionTicks, 0);
      expect(movie.imageTags, isEmpty);
    });

    test('a full item', () {
      final movie = BaseItemDto.fromJson(fixture('item_movie'));
      expect(movie.name, 'Test Movie (2020)');
      expect(movie.type.isFolder, isFalse);
      expect(movie.runTimeTicks, greaterThan(0));
    });

    test('seasons and episodes carry their series', () {
      final season = page('seasons').items.single;
      expect(season.type, BaseItemKind.season);
      expect(season.indexNumber, 1);
      expect(season.userData!.unplayedItemCount, 3);

      final episodes = page('episodes').items;
      expect(episodes.map((e) => e.indexNumber), [1, 2, 3]);
      final first = episodes.first;
      expect(first.type, BaseItemKind.episode);
      expect(first.seriesId, season.seriesId);
      expect(first.seasonId, season.id);
      expect(first.seriesName, 'Test Show');
      expect(first.parentIndexNumber, 1);
    });

    test('latest is a bare array', () {
      final latest = [
        for (final e in read('items_latest')! as List)
          BaseItemDto.fromJson(e as Map<String, dynamic>),
      ];
      expect(latest.single.type, BaseItemKind.series);
    });

    test('a kind the app does not know parses as unknown', () {
      final item = BaseItemDto.fromJson({
        'Id': 'x',
        'Name': 'A book',
        'Type': 'Book',
      });
      expect(item.type, BaseItemKind.unknown);
      expect(BaseItemKind.musicAlbum.jsonValue, 'MusicAlbum');
    });
  });
}
