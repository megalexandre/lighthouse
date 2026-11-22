import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'log.dart';

/// The file with the system's certificate authorities, for mpv to check
/// HTTPS servers against; null where mpv finds them by itself. Made once
/// per run, so it follows the system's updates.
///
/// On Android there is no such file, and the TLS library in mpv's ffmpeg
/// (mbedTLS) knows no other place to look: every certificate would be
/// refused. The activity writes one (MainActivity.kt).
final systemCertificatesProvider = FutureProvider<String?>((_) async {
  if (!Platform.isAndroid) return null;
  try {
    return await const MethodChannel('lighthouse/device')
        .invokeMethod<String>('certificates');
  } on PlatformException catch (e) {
    // Certificates are still checked: video over HTTPS will not play, but
    // the session's token does not go to whoever answers.
    log.error('tls', 'cannot read the system certificates', e.message);
    return null;
  }
});
