import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:media_kit/media_kit.dart';

import 'app.dart';
import 'core/config.dart';
import 'core/log.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await log.openFile(defaultLogDirectory());
  } on FileSystemException catch (e) {
    // No log file (read-only home?): the console still gets every line.
    log.warning('app', 'cannot write the log file', e);
  }
  log.info('app', '$clientName $appVersion starting; log: ${log.file?.path}');

  // Errors nothing caught: logged, then the default handling.
  final flutterError = FlutterError.onError;
  FlutterError.onError = (details) {
    log.error('flutter', details.exceptionAsString(), null, details.stack);
    flutterError?.call(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    log.error('app', 'uncaught error', error, stack);
    return false;
  };

  MediaKit.ensureInitialized();
  runApp(const ProviderScope(retry: noAutomaticRetry, child: JellyfinApp()));
}
