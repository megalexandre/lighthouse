// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lighthouse';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageHelp =>
      'Of the app\'s texts. Titles and descriptions come from the server, in its language.';

  @override
  String failureUnreachable(String url) {
    return 'Cannot reach $url. Check the address and that the server is running.';
  }

  @override
  String failureNotJellyfin(String url) {
    return '$url does not look like a Jellyfin server.';
  }

  @override
  String failureDifferentServer(String url) {
    return '$url reaches a different Jellyfin server than the first address.';
  }

  @override
  String failureNotSetUp(String url) {
    return 'The server at $url is not set up yet. Open it in a browser and finish the setup wizard first.';
  }

  @override
  String get failureUnauthorized => 'Wrong username or password.';

  @override
  String get failureServerBadCertificate =>
      'The server\'s security certificate is not valid.';

  @override
  String get failureServerUnexpected => 'Unexpected response from the server.';

  @override
  String failureServerStatus(int status) {
    return 'The server answered with error $status.';
  }

  @override
  String get failureStorageKeyring =>
      'Could not save the login in the system keyring.';

  @override
  String get failureStorageDisk => 'Could not save to disk.';

  @override
  String failureNotPlayable(String reason) {
    return 'This item cannot be played ($reason).';
  }

  @override
  String get failurePlayer =>
      'Playback failed: the stream could not be opened.';

  @override
  String get failureNotReadable => 'This book\'s format is not supported yet.';

  @override
  String get errorUnknown => 'Something went wrong.';

  @override
  String get retry => 'Retry';

  @override
  String get back => 'Back';

  @override
  String get more => 'More';

  @override
  String runtimeHoursMinutes(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String runtimeHours(int hours) {
    return '${hours}h';
  }

  @override
  String runtimeMinutes(int minutes) {
    return '${minutes}m';
  }

  @override
  String runtimeSeconds(int seconds) {
    return '${seconds}s';
  }

  @override
  String episodeNumber(int season, int episode) {
    return 'S$season:E$episode';
  }

  @override
  String episodeOnly(int episode) {
    return 'E$episode';
  }

  @override
  String get bookRead => 'Read';

  @override
  String bookPercentRead(int percent) {
    return '$percent% read';
  }

  @override
  String get signIn => 'Sign in';

  @override
  String serverNameAndUrl(String name, String url) {
    return '$name · $url';
  }

  @override
  String get username => 'Username';

  @override
  String get usernameMissing => 'Enter your username.';

  @override
  String get password => 'Password';

  @override
  String get changeServer => 'Change server';

  @override
  String get connectTitle => 'Connect to a server';

  @override
  String get connectSubtitle => 'Enter the address of your Jellyfin server.';

  @override
  String get serverAddress => 'Server address';

  @override
  String get fallbackAddress => 'Fallback address (optional)';

  @override
  String get fallbackAddressHint =>
      'Used when the first one does not answer, e.g. away from home.';

  @override
  String get serverAddressMissing => 'Enter the server address.';

  @override
  String get connect => 'Connect';

  @override
  String offlineBanner(String server) {
    return 'Can\'t reach $server. Trying again…';
  }

  @override
  String get theServer => 'the server';

  @override
  String get retryNow => 'Retry now';

  @override
  String get home => 'Home';

  @override
  String get searchTooltip => 'Search (Ctrl+F)';

  @override
  String get searchHintShort => 'Titles, people, genres';

  @override
  String get darkTheme => 'Dark theme';

  @override
  String get lightTheme => 'Light theme';

  @override
  String get settings => 'Settings';

  @override
  String get signOut => 'Sign out';

  @override
  String get signedOutNotice => 'You signed out.';

  @override
  String get sessionExpiredNotice => 'Your session ended. Sign in again.';

  @override
  String get profile => 'Profile';

  @override
  String get heroMovie => 'MOVIE';

  @override
  String get heroSeries => 'SERIES';

  @override
  String get play => 'Play';

  @override
  String playEpisode(String episode) {
    return 'Play $episode';
  }

  @override
  String get episodes => 'Episodes';

  @override
  String get moreInfo => 'More info';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get slide => 'Slide';

  @override
  String get noLibraries =>
      'No libraries yet. Add one on the server, or ask its administrator for access.';

  @override
  String get continueWatching => 'Continue watching';

  @override
  String get nextUp => 'Next up';

  @override
  String get continueReading => 'Continue reading';

  @override
  String latestIn(String library) {
    return 'Latest in $library';
  }

  @override
  String get myMedia => 'My media';

  @override
  String get read => 'Read';

  @override
  String get resume => 'Resume';

  @override
  String seasonCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seasons',
      one: '1 season',
    );
    return '$_temp0';
  }

  @override
  String get markUnwatched => 'Mark as unwatched';

  @override
  String get markWatched => 'Mark as watched';

  @override
  String get details => 'Details';

  @override
  String get nothingHere => 'Nothing here yet.';

  @override
  String get searchHint => 'Search movies, shows, music';

  @override
  String nothingFound(String term) {
    return 'Nothing found for \"$term\".';
  }

  @override
  String get movies => 'Movies';

  @override
  String get shows => 'Shows';

  @override
  String get albums => 'Albums';

  @override
  String get songs => 'Songs';

  @override
  String get books => 'Books';

  @override
  String resumeFrom(String position) {
    return 'Resume from $position';
  }

  @override
  String get startOver => 'Start over';

  @override
  String continueReadingPercent(int percent) {
    return 'Continue reading · $percent%';
  }

  @override
  String get markUnread => 'Mark as unread';

  @override
  String get markRead => 'Mark as read';

  @override
  String get watched => 'Watched';

  @override
  String get seasons => 'Seasons';

  @override
  String get tracks => 'Tracks';

  @override
  String get playback => 'Playback';

  @override
  String get maxQuality => 'Maximum quality';

  @override
  String get maxQualityHelp =>
      'On this device. Above it the server converts the video down; lower it on a slow network.';

  @override
  String get qualityMaximum => 'Maximum';

  @override
  String get appearance => 'Appearance';

  @override
  String get account => 'Account';

  @override
  String get audioLanguage => 'Audio language';

  @override
  String get audioLanguageHelp =>
      'Played when a file has it. Saved for your account on the server.';

  @override
  String get fileDefault => 'The file\'s default';

  @override
  String get subtitleLanguage => 'Subtitle language';

  @override
  String get anyLanguage => 'Any';

  @override
  String get showSubtitles => 'Show subtitles';

  @override
  String get subtitlesDefault => 'When the file says so';

  @override
  String get subtitlesSmart => 'When the audio is in another language';

  @override
  String get subtitlesAlways => 'Always';

  @override
  String get subtitlesForced => 'Only forced subtitles';

  @override
  String get subtitlesNever => 'Never';

  @override
  String get autoplayNext => 'Play the next episode automatically';

  @override
  String themeNotUsed(String file, String error) {
    return '$file: not used ($error)';
  }

  @override
  String get theme => 'Theme';

  @override
  String get themeHelp => 'Colours, type and shapes, from a design system.';

  @override
  String themeFromFolder(String name) {
    return '$name (your folder)';
  }

  @override
  String get mode => 'Mode';

  @override
  String get singleMode => 'This theme has a single mode.';

  @override
  String get modeDark => 'Dark';

  @override
  String get modeLight => 'Light';

  @override
  String get modeSystem => 'System';

  @override
  String get yourThemes => 'Your themes';

  @override
  String yourThemesHelp(String folder) {
    return 'Put a design system\'s tokens.json in $folder: it shows up here at once, and changes to it apply as you save.';
  }

  @override
  String get openFolder => 'Open folder';

  @override
  String themeIssues(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count theme issues',
      one: '1 theme issue',
    );
    return '$_temp0';
  }

  @override
  String playbackStopped(String position) {
    return 'Playback stopped at $position: the connection to the server was lost.';
  }

  @override
  String get trackChangeFailed => 'Could not change the track.';

  @override
  String get subtitlesOff => 'Off';

  @override
  String withShortcut(String label, String shortcut) {
    return '$label ($shortcut)';
  }

  @override
  String get keySpace => 'Space';

  @override
  String get back10 => 'Back 10 seconds';

  @override
  String get pause => 'Pause';

  @override
  String get forward10 => 'Forward 10 seconds';

  @override
  String get subtitles => 'Subtitles';

  @override
  String get fullScreen => 'Full screen';

  @override
  String get exitFullScreen => 'Exit full screen';

  @override
  String get mute => 'Mute';

  @override
  String get unmute => 'Unmute';

  @override
  String get transcoding => 'Transcoding';

  @override
  String get seekPosition => 'Position';

  @override
  String hours(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours',
      one: '1 hour',
    );
    return '$_temp0';
  }

  @override
  String minutes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes',
      one: '1 minute',
    );
    return '$_temp0';
  }

  @override
  String seconds(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seconds',
      one: '1 second',
    );
    return '$_temp0';
  }

  @override
  String positionOf(String position, String length) {
    return '$position of $length';
  }

  @override
  String get speedNormal => 'Normal';

  @override
  String get audio => 'Audio';

  @override
  String get speed => 'Speed';

  @override
  String endsAt(String time) {
    return 'Ends at $time';
  }

  @override
  String get watchNow => 'Watch now';

  @override
  String get hide => 'Hide';

  @override
  String upNextIn(int seconds) {
    return 'UP NEXT · IN $seconds S';
  }

  @override
  String trackNumber(int number) {
    return 'Track $number';
  }

  @override
  String backToPage(int page) {
    return 'Back to page $page';
  }

  @override
  String get contentsAndBookmarks => 'Contents and bookmarks';

  @override
  String get removeBookmark => 'Remove bookmark';

  @override
  String get bookmarkPage => 'Bookmark this page';

  @override
  String get display => 'Display';

  @override
  String pageOf(int page, int count) {
    return 'Page $page of $count';
  }

  @override
  String get contents => 'Contents';

  @override
  String get bookmarks => 'Bookmarks';

  @override
  String get noContents => 'This book has no table of contents.';

  @override
  String get noBookmarks =>
      'No bookmarks yet. The bookmark button at the top marks the page you are on.';

  @override
  String page(int page) {
    return 'Page $page';
  }

  @override
  String get smallerText => 'Smaller text';

  @override
  String fontSizePx(int size) {
    return '$size px';
  }

  @override
  String get largerText => 'Larger text';

  @override
  String get serif => 'Serif';

  @override
  String get sans => 'Sans';

  @override
  String get readerLight => 'Light';

  @override
  String get readerSepia => 'Sepia';

  @override
  String get readerDark => 'Dark';

  @override
  String trackTitled(String language, String title) {
    return '$language · $title';
  }

  @override
  String get trackForced => 'Forced';
}
