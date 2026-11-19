import '../../../api/models/media_stream.dart';
import '../../../api/models/playback_report.dart';
import '../../../api/playback.dart';
import '../../../l10n/l10n.dart';
import 'playback_plan.dart';

/// What the player has to do to show a chosen audio or subtitle track.
sealed class TrackAction {
  const TrackAction();
}

/// Pick one of the file's own tracks, by mpv's track id ("1", "2"...).
final class SelectTrack extends TrackAction {
  const SelectTrack(this.mpvId);
  final String mpvId;

  @override
  bool operator ==(Object other) =>
      other is SelectTrack && other.mpvId == mpvId;
  @override
  int get hashCode => mpvId.hashCode;
  @override
  String toString() => 'SelectTrack($mpvId)';
}

/// Show no subtitle.
final class HideSubtitles extends TrackAction {
  const HideSubtitles();
  @override
  String toString() => 'HideSubtitles';
}

/// Load a subtitle file from the server and show it.
final class AddSubtitle extends TrackAction {
  const AddSubtitle(this.url, {this.title, this.language});

  /// Carries an access token: never log it.
  final Uri url;
  final String? title;
  final String? language;

  @override
  bool operator ==(Object other) => other is AddSubtitle && other.url == url;
  @override
  int get hashCode => url.hashCode;
  @override
  String toString() => 'AddSubtitle(${url.path})';
}

/// Ask the server for a new stream with this track (a transcode carries
/// only the tracks it was made with).
final class RestartStream extends TrackAction {
  const RestartStream();
  @override
  String toString() => 'RestartStream';
}

/// mpv's id for [stream], one of the file's own tracks: mpv numbers each
/// kind from 1 in file order, and the server's indexes follow file order
/// too (external files aside), so it is the stream's rank among the
/// file's tracks of its kind. Null for an external stream.
String? mpvTrackId(PlaybackPlan plan, MediaStream stream) {
  if (stream.isExternal) return null;
  final sameKind = [
    for (final s in plan.source.mediaStreams)
      if (s.type == stream.type && !s.isExternal) s.index,
  ]..sort();
  final rank = sameKind.indexOf(stream.index);
  return rank < 0 ? null : '${rank + 1}';
}

/// How to switch to the audio track [streamIndex].
TrackAction audioAction(PlaybackPlan plan, int streamIndex) {
  if (plan.method == PlayMethod.transcode) return const RestartStream();
  final stream = _stream(plan, streamIndex, MediaStreamType.audio);
  final id = mpvTrackId(plan, stream);
  return id == null ? const RestartStream() : SelectTrack(id);
}

/// How to switch to the subtitle [streamIndex], or to none when null.
TrackAction subtitleAction(
  PlaybackPlan plan,
  int? streamIndex, {
  required String baseUrl,
}) {
  if (streamIndex == null) return const HideSubtitles();
  final stream = _stream(plan, streamIndex, MediaStreamType.subtitle);
  if (stream.deliveryMethod == SubtitleDeliveryMethod.external &&
      stream.deliveryUrl != null) {
    return AddSubtitle(
      serverUrl(baseUrl, stream.deliveryUrl!),
      title: stream.displayTitle ?? stream.title,
      language: stream.language,
    );
  }
  if (plan.method == PlayMethod.transcode) return const RestartStream();
  final id = mpvTrackId(plan, stream);
  return id == null ? const RestartStream() : SelectTrack(id);
}

MediaStream _stream(PlaybackPlan plan, int index, MediaStreamType type) =>
    plan.source.mediaStreams.firstWhere(
      (s) => s.index == index && s.type == type,
      orElse: () => throw ArgumentError('no $type stream $index'),
    );

/// The next track index after [current] in [indexes], wrapping around;
/// with [includeNone], "none" (null) sits between the last and the first.
int? cycle(List<int> indexes, int? current, {bool includeNone = false}) {
  if (indexes.isEmpty) return null;
  final options = <int?>[if (includeNone) null, ...indexes];
  final at = options.indexOf(current);
  return options[(at + 1) % options.length];
}

/// [cycle] backwards.
int? cycleBack(List<int> indexes, int? current, {bool includeNone = false}) {
  if (indexes.isEmpty) return null;
  final options = <int?>[if (includeNone) null, ...indexes];
  final at = options.indexOf(current);
  return options[(at <= 0 ? options.length : at) - 1];
}

/// Label of a track in the menus: its language in the app's language
/// ("Português"; the server's label is in English), then the track's own
/// title unless that only names the language ("English", "Português").
/// A track whose language the app cannot name keeps the server's label.
String trackLabel(MediaStream stream, AppLocalizations l10n) {
  final language = languageName(stream.language, l10n);
  final title = stream.title?.trim();
  final ownTitle =
      title != null &&
          title.isNotEmpty &&
          !namesLanguage(title, stream.language)
      ? title
      : null;
  if (language != null) {
    return ownTitle == null ? language : l10n.trackTitled(language, ownTitle);
  }
  return stream.displayTitle ?? ownTitle ?? l10n.trackNumber(stream.index);
}

/// The grey detail beside a track: its format ("AAC", "SRT"), and
/// "Forced" for a forced subtitle.
String? trackDetail(MediaStream stream, AppLocalizations l10n) {
  final parts = [
    if (stream.codec case final String codec when codec.isNotEmpty)
      _formats[codec.toLowerCase()] ?? codec.toUpperCase(),
    if (stream.isForced) l10n.trackForced,
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

/// Formats whose ffmpeg name is not the one people know.
const _formats = {
  'subrip': 'SRT',
  'hdmv_pgs_subtitle': 'PGS',
  'pgssub': 'PGS',
  'dvd_subtitle': 'VOBSUB',
  'dvdsub': 'VOBSUB',
  'webvtt': 'VTT',
  'mov_text': 'TX3G',
  'eac3': 'E-AC3',
  'truehd': 'TrueHD',
};
