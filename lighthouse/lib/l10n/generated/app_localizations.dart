import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// The window's title.
  ///
  /// In en, this message translates to:
  /// **'Lighthouse'**
  String get appTitle;

  /// Settings → Appearance: the language of the app's texts.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Under Settings → Appearance → Language.
  ///
  /// In en, this message translates to:
  /// **'Of the app\'s texts. Titles and descriptions come from the server, in its language.'**
  String get settingsLanguageHelp;

  /// A server did not answer.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach {url}. Check the address and that the server is running.'**
  String failureUnreachable(String url);

  /// Something answered at the address, but not Jellyfin.
  ///
  /// In en, this message translates to:
  /// **'{url} does not look like a Jellyfin server.'**
  String failureNotJellyfin(String url);

  /// The server's setup wizard was never finished.
  ///
  /// In en, this message translates to:
  /// **'The server at {url} is not set up yet. Open it in a browser and finish the setup wizard first.'**
  String failureNotSetUp(String url);

  /// Sign-in refused (also shown when a session ends).
  ///
  /// In en, this message translates to:
  /// **'Wrong username or password.'**
  String get failureUnauthorized;

  /// HTTPS certificate rejected.
  ///
  /// In en, this message translates to:
  /// **'The server\'s security certificate is not valid.'**
  String get failureServerBadCertificate;

  /// The server sent something the app cannot read.
  ///
  /// In en, this message translates to:
  /// **'Unexpected response from the server.'**
  String get failureServerUnexpected;

  /// An HTTP error status, e.g. 500.
  ///
  /// In en, this message translates to:
  /// **'The server answered with error {status}.'**
  String failureServerStatus(int status);

  /// The system keyring refused the session.
  ///
  /// In en, this message translates to:
  /// **'Could not save the login in the system keyring.'**
  String get failureStorageKeyring;

  /// A file of the app could not be written.
  ///
  /// In en, this message translates to:
  /// **'Could not save to disk.'**
  String get failureStorageDisk;

  /// reason: the server's code, e.g. NotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This item cannot be played ({reason}).'**
  String failureNotPlayable(String reason);

  /// mpv could not open the stream.
  ///
  /// In en, this message translates to:
  /// **'Playback failed: the stream could not be opened.'**
  String get failurePlayer;

  /// A book the reader cannot open.
  ///
  /// In en, this message translates to:
  /// **'This book\'s format is not supported yet.'**
  String get failureNotReadable;

  /// An error with no better description.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorUnknown;

  /// Button after an error.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Back button / tooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// Tooltip of a row's forward arrow.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// A length, e.g. 1h 52m.
  ///
  /// In en, this message translates to:
  /// **'{hours}h {minutes}m'**
  String runtimeHoursMinutes(int hours, int minutes);

  /// A length in whole hours.
  ///
  /// In en, this message translates to:
  /// **'{hours}h'**
  String runtimeHours(int hours);

  /// A length under an hour.
  ///
  /// In en, this message translates to:
  /// **'{minutes}m'**
  String runtimeMinutes(int minutes);

  /// A length under a minute.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String runtimeSeconds(int seconds);

  /// Season and episode, e.g. S1:E2.
  ///
  /// In en, this message translates to:
  /// **'S{season}:E{episode}'**
  String episodeNumber(int season, int episode);

  /// An episode number without a season.
  ///
  /// In en, this message translates to:
  /// **'E{episode}'**
  String episodeOnly(int episode);

  /// Under a book's cover: finished.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get bookRead;

  /// Under a book's cover: how far along.
  ///
  /// In en, this message translates to:
  /// **'{percent}% read'**
  String bookPercentRead(int percent);

  /// Title of the login screen and its button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Under the login title: the server.
  ///
  /// In en, this message translates to:
  /// **'{name} · {url}'**
  String serverNameAndUrl(String name, String url);

  /// Login field.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// Login without a username.
  ///
  /// In en, this message translates to:
  /// **'Enter your username.'**
  String get usernameMissing;

  /// Login field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Login screen: back to the server choice.
  ///
  /// In en, this message translates to:
  /// **'Change server'**
  String get changeServer;

  /// Title of the first screen.
  ///
  /// In en, this message translates to:
  /// **'Connect to a server'**
  String get connectTitle;

  /// Under the connect title.
  ///
  /// In en, this message translates to:
  /// **'Enter the address of your Jellyfin server.'**
  String get connectSubtitle;

  /// Connect screen field.
  ///
  /// In en, this message translates to:
  /// **'Server address'**
  String get serverAddress;

  /// Connect without an address.
  ///
  /// In en, this message translates to:
  /// **'Enter the server address.'**
  String get serverAddressMissing;

  /// Connect screen button.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Banner while the server is down.
  ///
  /// In en, this message translates to:
  /// **'Can\'t reach {server}. Trying again…'**
  String offlineBanner(String server);

  /// In the offline banner when the server has no name.
  ///
  /// In en, this message translates to:
  /// **'the server'**
  String get theServer;

  /// Offline banner button.
  ///
  /// In en, this message translates to:
  /// **'Retry now'**
  String get retryNow;

  /// Top bar tab and the app mark's label.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Search button tooltip, with its shortcut.
  ///
  /// In en, this message translates to:
  /// **'Search (Ctrl+F)'**
  String get searchTooltip;

  /// Hint in the top bar's search field.
  ///
  /// In en, this message translates to:
  /// **'Titles, people, genres'**
  String get searchHintShort;

  /// Profile menu: switch to the dark mode.
  ///
  /// In en, this message translates to:
  /// **'Dark theme'**
  String get darkTheme;

  /// Profile menu: switch to the light mode.
  ///
  /// In en, this message translates to:
  /// **'Light theme'**
  String get lightTheme;

  /// Settings screen title, menu item and tooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Sign-out button and menu item.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Tooltip of the profile disc when the user has no name.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Carousel label over a movie (capitals).
  ///
  /// In en, this message translates to:
  /// **'MOVIE'**
  String get heroMovie;

  /// Carousel label over a series (capitals).
  ///
  /// In en, this message translates to:
  /// **'SERIES'**
  String get heroSeries;

  /// Play button.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// Episodes: a series' button, a section, a search group.
  ///
  /// In en, this message translates to:
  /// **'Episodes'**
  String get episodes;

  /// Carousel button to the item's page.
  ///
  /// In en, this message translates to:
  /// **'More info'**
  String get moreInfo;

  /// Next item / slide.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// Previous item / slide.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// A carousel dot, for screen readers.
  ///
  /// In en, this message translates to:
  /// **'Slide'**
  String get slide;

  /// Home with no library.
  ///
  /// In en, this message translates to:
  /// **'No libraries yet. Add one on the server, or ask its administrator for access.'**
  String get noLibraries;

  /// Home row.
  ///
  /// In en, this message translates to:
  /// **'Continue watching'**
  String get continueWatching;

  /// Home row: next episodes of shows in progress.
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get nextUp;

  /// Home row; a book's button once started.
  ///
  /// In en, this message translates to:
  /// **'Continue reading'**
  String get continueReading;

  /// Home row per library.
  ///
  /// In en, this message translates to:
  /// **'Latest in {library}'**
  String latestIn(String library);

  /// Home row with the libraries.
  ///
  /// In en, this message translates to:
  /// **'My media'**
  String get myMedia;

  /// Button that opens a book.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get read;

  /// Card panel: play from where it stopped.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// How many seasons a series has.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 season} other{{count} seasons}}'**
  String seasonCount(int count);

  /// Watched toggle, on.
  ///
  /// In en, this message translates to:
  /// **'Mark as unwatched'**
  String get markUnwatched;

  /// Watched toggle, off.
  ///
  /// In en, this message translates to:
  /// **'Mark as watched'**
  String get markWatched;

  /// Card panel: open the item's page.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get details;

  /// An empty library or section.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get nothingHere;

  /// Hint in the search screen's field.
  ///
  /// In en, this message translates to:
  /// **'Search movies, shows, music'**
  String get searchHint;

  /// Search without results.
  ///
  /// In en, this message translates to:
  /// **'Nothing found for \"{term}\".'**
  String nothingFound(String term);

  /// Search results group.
  ///
  /// In en, this message translates to:
  /// **'Movies'**
  String get movies;

  /// Search results group.
  ///
  /// In en, this message translates to:
  /// **'Shows'**
  String get shows;

  /// Search results group.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get albums;

  /// Search results group.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs;

  /// Search results group.
  ///
  /// In en, this message translates to:
  /// **'Books'**
  String get books;

  /// Item page: play from the saved place, e.g. 12:34.
  ///
  /// In en, this message translates to:
  /// **'Resume from {position}'**
  String resumeFrom(String position);

  /// Item page: play from the start.
  ///
  /// In en, this message translates to:
  /// **'Start over'**
  String get startOver;

  /// A started book's button.
  ///
  /// In en, this message translates to:
  /// **'Continue reading · {percent}%'**
  String continueReadingPercent(int percent);

  /// Read toggle on a book, on.
  ///
  /// In en, this message translates to:
  /// **'Mark as unread'**
  String get markUnread;

  /// Read toggle on a book, off.
  ///
  /// In en, this message translates to:
  /// **'Mark as read'**
  String get markRead;

  /// Item page: already watched.
  ///
  /// In en, this message translates to:
  /// **'Watched'**
  String get watched;

  /// Series page section.
  ///
  /// In en, this message translates to:
  /// **'Seasons'**
  String get seasons;

  /// Album page section.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get tracks;

  /// Settings heading.
  ///
  /// In en, this message translates to:
  /// **'Playback'**
  String get playback;

  /// Settings: streaming bitrate limit.
  ///
  /// In en, this message translates to:
  /// **'Maximum quality'**
  String get maxQuality;

  /// Under Maximum quality.
  ///
  /// In en, this message translates to:
  /// **'On this device. Above it the server converts the video down; lower it on a slow network.'**
  String get maxQualityHelp;

  /// Maximum quality: no limit.
  ///
  /// In en, this message translates to:
  /// **'Maximum'**
  String get qualityMaximum;

  /// Settings heading.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Settings heading.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// Settings: preferred audio language.
  ///
  /// In en, this message translates to:
  /// **'Audio language'**
  String get audioLanguage;

  /// Under Audio language.
  ///
  /// In en, this message translates to:
  /// **'Played when a file has it. Saved for your account on the server.'**
  String get audioLanguageHelp;

  /// Audio language: none preferred.
  ///
  /// In en, this message translates to:
  /// **'The file\'s default'**
  String get fileDefault;

  /// Settings: preferred subtitle language.
  ///
  /// In en, this message translates to:
  /// **'Subtitle language'**
  String get subtitleLanguage;

  /// Subtitle language: none preferred.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get anyLanguage;

  /// Settings: when subtitles show.
  ///
  /// In en, this message translates to:
  /// **'Show subtitles'**
  String get showSubtitles;

  /// Show subtitles: the file's default.
  ///
  /// In en, this message translates to:
  /// **'When the file says so'**
  String get subtitlesDefault;

  /// Show subtitles: smart.
  ///
  /// In en, this message translates to:
  /// **'When the audio is in another language'**
  String get subtitlesSmart;

  /// Show subtitles.
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get subtitlesAlways;

  /// Show subtitles.
  ///
  /// In en, this message translates to:
  /// **'Only forced subtitles'**
  String get subtitlesForced;

  /// Show subtitles.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get subtitlesNever;

  /// Settings switch.
  ///
  /// In en, this message translates to:
  /// **'Play the next episode automatically'**
  String get autoplayNext;

  /// A theme file that could not be read; error is technical.
  ///
  /// In en, this message translates to:
  /// **'{file}: not used ({error})'**
  String themeNotUsed(String file, String error);

  /// Settings: the theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Under Theme.
  ///
  /// In en, this message translates to:
  /// **'Colours, type and shapes, from a design system.'**
  String get themeHelp;

  /// A theme from the user's themes folder.
  ///
  /// In en, this message translates to:
  /// **'{name} (your folder)'**
  String themeFromFolder(String name);

  /// Settings: light, dark or system.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// Under Mode when the theme has one.
  ///
  /// In en, this message translates to:
  /// **'This theme has a single mode.'**
  String get singleMode;

  /// Mode choice.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get modeDark;

  /// Mode choice.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get modeLight;

  /// Mode choice: follow the system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get modeSystem;

  /// Settings: the user's themes folder.
  ///
  /// In en, this message translates to:
  /// **'Your themes'**
  String get yourThemes;

  /// Under Your themes.
  ///
  /// In en, this message translates to:
  /// **'Put a design system\'s tokens.json in {folder}: it shows up here at once, and changes to it apply as you save.'**
  String yourThemesHelp(String folder);

  /// Opens the themes folder.
  ///
  /// In en, this message translates to:
  /// **'Open folder'**
  String get openFolder;

  /// Theme files with problems.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 theme issue} other{{count} theme issues}}'**
  String themeIssues(int count);

  /// The stream broke off; position e.g. 12:34.
  ///
  /// In en, this message translates to:
  /// **'Playback stopped at {position}: the connection to the server was lost.'**
  String playbackStopped(String position);

  /// Snack bar when an audio or subtitle change fails.
  ///
  /// In en, this message translates to:
  /// **'Could not change the track.'**
  String get trackChangeFailed;

  /// Subtitle menu: no subtitles.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get subtitlesOff;

  /// A button's tooltip with its key, e.g. Pause (Space).
  ///
  /// In en, this message translates to:
  /// **'{label} ({shortcut})'**
  String withShortcut(String label, String shortcut);

  /// The space bar, in tooltips.
  ///
  /// In en, this message translates to:
  /// **'Space'**
  String get keySpace;

  /// Player button.
  ///
  /// In en, this message translates to:
  /// **'Back 10 seconds'**
  String get back10;

  /// Player button.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// Player button.
  ///
  /// In en, this message translates to:
  /// **'Forward 10 seconds'**
  String get forward10;

  /// Player button and menu.
  ///
  /// In en, this message translates to:
  /// **'Subtitles'**
  String get subtitles;

  /// Player button.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get fullScreen;

  /// Player button.
  ///
  /// In en, this message translates to:
  /// **'Exit full screen'**
  String get exitFullScreen;

  /// Player button.
  ///
  /// In en, this message translates to:
  /// **'Mute'**
  String get mute;

  /// Player button.
  ///
  /// In en, this message translates to:
  /// **'Unmute'**
  String get unmute;

  /// Badge: the server converts the stream.
  ///
  /// In en, this message translates to:
  /// **'Transcoding'**
  String get transcoding;

  /// Seek bar, for screen readers.
  ///
  /// In en, this message translates to:
  /// **'Position'**
  String get seekPosition;

  /// For screen readers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour} other{{count} hours}}'**
  String hours(int count);

  /// For screen readers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute} other{{count} minutes}}'**
  String minutes(int count);

  /// For screen readers.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 second} other{{count} seconds}}'**
  String seconds(int count);

  /// Seek bar for screen readers: 3 minutes of 1 hour.
  ///
  /// In en, this message translates to:
  /// **'{position} of {length}'**
  String positionOf(String position, String length);

  /// Playback speed 1×.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get speedNormal;

  /// Player menu.
  ///
  /// In en, this message translates to:
  /// **'Audio'**
  String get audio;

  /// Player menu.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get speed;

  /// Up next card: when the next episode would end.
  ///
  /// In en, this message translates to:
  /// **'Ends at {time}'**
  String endsAt(String time);

  /// Up next card button.
  ///
  /// In en, this message translates to:
  /// **'Watch now'**
  String get watchNow;

  /// Up next card button.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// Up next card countdown (capitals).
  ///
  /// In en, this message translates to:
  /// **'UP NEXT · IN {seconds} S'**
  String upNextIn(int seconds);

  /// A track with no title or language.
  ///
  /// In en, this message translates to:
  /// **'Track {number}'**
  String trackNumber(int number);

  /// After following a link in a book.
  ///
  /// In en, this message translates to:
  /// **'Back to page {page}'**
  String backToPage(int page);

  /// Reader button.
  ///
  /// In en, this message translates to:
  /// **'Contents and bookmarks'**
  String get contentsAndBookmarks;

  /// Reader: bookmark on this page.
  ///
  /// In en, this message translates to:
  /// **'Remove bookmark'**
  String get removeBookmark;

  /// Reader: no bookmark here.
  ///
  /// In en, this message translates to:
  /// **'Bookmark this page'**
  String get bookmarkPage;

  /// Reader button: type size, typeface, theme.
  ///
  /// In en, this message translates to:
  /// **'Display'**
  String get display;

  /// Reader page counter.
  ///
  /// In en, this message translates to:
  /// **'Page {page} of {count}'**
  String pageOf(int page, int count);

  /// Reader tab.
  ///
  /// In en, this message translates to:
  /// **'Contents'**
  String get contents;

  /// Reader tab.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get bookmarks;

  /// Contents tab, empty.
  ///
  /// In en, this message translates to:
  /// **'This book has no table of contents.'**
  String get noContents;

  /// Bookmarks tab, empty.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet. The bookmark button at the top marks the page you are on.'**
  String get noBookmarks;

  /// A bookmark's page.
  ///
  /// In en, this message translates to:
  /// **'Page {page}'**
  String page(int page);

  /// Reader display.
  ///
  /// In en, this message translates to:
  /// **'Smaller text'**
  String get smallerText;

  /// The type size, e.g. 18 px.
  ///
  /// In en, this message translates to:
  /// **'{size} px'**
  String fontSizePx(int size);

  /// Reader display.
  ///
  /// In en, this message translates to:
  /// **'Larger text'**
  String get largerText;

  /// Reader typeface.
  ///
  /// In en, this message translates to:
  /// **'Serif'**
  String get serif;

  /// Reader typeface.
  ///
  /// In en, this message translates to:
  /// **'Sans'**
  String get sans;

  /// Reader theme.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get readerLight;

  /// Reader theme.
  ///
  /// In en, this message translates to:
  /// **'Sepia'**
  String get readerSepia;

  /// Reader theme.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get readerDark;

  /// An audio or subtitle track: its language, then its own title ("Director's commentary").
  ///
  /// In en, this message translates to:
  /// **'{language} · {title}'**
  String trackTitled(String language, String title);

  /// Detail of a forced subtitle (one shown only for foreign speech or signs).
  ///
  /// In en, this message translates to:
  /// **'Forced'**
  String get trackForced;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
