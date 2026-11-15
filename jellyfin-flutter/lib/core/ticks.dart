/// Jellyfin measures time in ticks of 100 ns (.NET TimeSpan ticks).
const ticksPerMicrosecond = 10;

Duration ticksToDuration(int ticks) =>
    Duration(microseconds: ticks ~/ ticksPerMicrosecond);

int durationToTicks(Duration duration) =>
    duration.inMicroseconds * ticksPerMicrosecond;

/// Length of a movie or episode as shown on cards: "1h 32m", "45m", "10s".
String formatRuntime(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes % 60;
  if (h > 0) return m == 0 ? '${h}h' : '${h}h ${m}m';
  if (m > 0) return '${m}m';
  return '${d.inSeconds}s';
}
