package io.github.megalexandre.lighthouse

import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Base64
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.KeyStore
import kotlin.concurrent.thread

// AudioServiceActivity: the engine it gives is the one audio_service plays
// music with, which must outlive the activity. With a plain FlutterActivity
// the plugin would start a second one.
class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // "name": the name the server shows for this device
        // (lib/api/client_info.dart). "certificates": the file mpv checks
        // HTTPS servers with (lib/core/system_certificates.dart).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lighthouse/device")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "name" -> result.success(deviceName())
                    "certificates" -> writeCertificates(result)
                    else -> result.notImplemented()
                }
            }
    }

    // The name the user gave the phone (Settings > About), else its model.
    // Dart's Platform.localHostname is "localhost" on Android.
    private fun deviceName(): String =
        Settings.Global.getString(contentResolver, Settings.Global.DEVICE_NAME)
            ?.takeIf { it.isNotBlank() }
            ?: Build.MODEL

    // The certificate authorities the system trusts, in one PEM file. Only
    // the system's: the API client (dart:io) trusts no others either, and
    // the two must agree on which servers are safe.
    private fun writeCertificates(result: MethodChannel.Result) {
        val directory = cacheDir
        val main = Handler(Looper.getMainLooper())
        thread {
            try {
                val store = KeyStore.getInstance("AndroidCAStore").apply { load(null) }
                val file = File(directory, "certificates.pem")
                // Written aside, then swapped in: mpv never reads half a file.
                val partial = File(directory, "certificates.pem.partial")
                partial.bufferedWriter().use { out ->
                    for (alias in store.aliases()) {
                        if (!alias.startsWith("system:")) continue
                        val certificate = store.getCertificate(alias) ?: continue
                        out.write("-----BEGIN CERTIFICATE-----\n")
                        // 64 characters a line, as PEM asks.
                        Base64.encodeToString(certificate.encoded, Base64.NO_WRAP)
                            .chunked(64)
                            .forEach { out.write("$it\n") }
                        out.write("-----END CERTIFICATE-----\n")
                    }
                }
                check(partial.renameTo(file)) { "cannot rename to $file" }
                main.post { result.success(file.path) }
            } catch (e: Exception) {
                main.post { result.error("certificates", e.message, null) }
            }
        }
    }
}
