import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// How bad a log line is.
enum LogLevel { debug, info, warning, error }

/// The app's log: every line goes to the console and, once [openFile] ran
/// (main does it), to a file that rotates at [maxFileBytes]. Lines are
/// [redact]ed first: tokens never reach a log.
///
/// One instance for the whole app ([log]), so code anywhere can write to
/// it without carrying it around.
class AppLog {
  AppLog({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  static const maxFileBytes = 5 * 1024 * 1024;

  /// How many rotated files (app.1.log, app.2.log...) are kept.
  static const keptFiles = 3;

  IOSink? _file;
  File? _path;
  int _written = 0;

  /// Lines also kept in memory, newest last (for tests, and a future
  /// "copy logs" in Settings).
  final recent = <String>[];
  static const recentLines = 500;

  /// Where the file is, once open.
  File? get file => _path;

  void debug(String tag, String message) =>
      _write(LogLevel.debug, tag, message);
  void info(String tag, String message) => _write(LogLevel.info, tag, message);
  void warning(String tag, String message, [Object? error]) =>
      _write(LogLevel.warning, tag, _with(message, error));
  void error(String tag, String message, [Object? error, StackTrace? stack]) =>
      _write(
        LogLevel.error,
        tag,
        [_with(message, error), if (stack != null) '$stack'].join('\n'),
      );

  String _with(String message, Object? error) =>
      error == null ? message : '$message: $error';

  void _write(LogLevel level, String tag, String message) {
    final line =
        '${_clock().toIso8601String()} ${level.name.toUpperCase()} '
        '[$tag] ${redact(message)}';
    recent.add(line);
    if (recent.length > recentLines) recent.removeAt(0);
    debugPrint(line);
    final file = _file;
    if (file == null) return;
    file.writeln(line);
    _written += line.length + 1;
    if (_written > maxFileBytes) unawaited(_rotate());
  }

  /// Starts writing to `app.log` in [directory] (rotating the one left by
  /// the last run).
  Future<void> openFile(Directory directory) async {
    await directory.create(recursive: true);
    _path = File('${directory.path}/app.log');
    await _rotate();
  }

  Future<void> _rotate() async {
    final path = _path;
    if (path == null) return;
    final old = _file;
    _file = null;
    await old?.flush();
    await old?.close();
    String name(int n) => '${path.parent.path}/app.$n.log';
    for (var n = keptFiles - 1; n >= 1; n--) {
      final f = File(name(n));
      if (f.existsSync()) await f.rename(name(n + 1));
    }
    if (path.existsSync()) await path.rename(name(1));
    final extra = File(name(keptFiles + 1));
    if (extra.existsSync()) await extra.delete();
    _file = path.openWrite();
    _written = 0;
  }

  Future<void> close() async {
    await _file?.flush();
    await _file?.close();
    _file = null;
  }
}

/// The app's log.
final log = AppLog();

/// Where main writes the log: [defaultLogDirectory] on Linux; elsewhere
/// (Android, which has no XDG_DATA_HOME or HOME) `logs` in the app's own
/// support folder.
Future<Directory> appLogDirectory() async => Platform.isLinux
    ? defaultLogDirectory()
    : Directory('${(await getApplicationSupportDirectory()).path}/logs');

/// The Linux log directory: `$XDG_DATA_HOME/lighthouse/logs`, by default
/// `~/.local/share/lighthouse/logs`.
Directory defaultLogDirectory([Map<String, String>? environment]) {
  final env = environment ?? Platform.environment;
  final data = env['XDG_DATA_HOME'];
  final base = data != null && data.isNotEmpty
      ? data
      : '${env['HOME'] ?? '.'}/.local/share';
  return Directory('$base/lighthouse/logs');
}

final _secrets = [
  // URL query: ?api_key=… / &ApiKey=… / access_token=… (any case).
  RegExp(r'((?:api_?key|access_?token|token)=)[^&\s"]+', caseSensitive: false),
  // Authorization header: Token="…".
  RegExp(r'(Token=")[^"]*', caseSensitive: false),
  // JSON: "AccessToken":"…", "Pw":"…", "Password":"…".
  RegExp(
    r'("(?:AccessToken|Pw|Password|NewPw|CurrentPw)"\s*:\s*")[^"]*',
    caseSensitive: false,
  ),
];

/// [text] with every token and password replaced by `***`.
String redact(String text) {
  var out = text;
  for (final pattern in _secrets) {
    out = out.replaceAllMapped(pattern, (m) => '${m[1]}***');
  }
  return out;
}
