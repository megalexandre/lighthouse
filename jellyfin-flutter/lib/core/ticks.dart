import '../l10n/generated/app_localizations.dart';

/// Jellyfin measures time in ticks of 100 ns (.NET TimeSpan ticks).
const ticksPerMicrosecond = 10;

Duration ticksToDuration(int ticks) =>
    Duration(microseconds: ticks ~/ ticksPerMicrosecond);

int durationToTicks(Duration duration) =>
    duration.inMicroseconds * ticksPerMicrosecond;

/// Length of a movie or episode as shown on cards: "1h 32m", "45m", "10s"
/// (in the app's language).
String formatRuntime(Duration d, AppLocalizations l10n) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h > 0) {
    return m == 0 ? l10n.runtimeHours(h) : l10n.runtimeHoursMinutes(h, m);
  }
  if (m > 0) return l10n.runtimeMinutes(m);
  return l10n.runtimeSeconds(d.inSeconds);
}

/// A position as shown by a player: "0:04", "12:30", "1:02:03".
String formatPosition(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  final s = (d.inSeconds % 60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}
