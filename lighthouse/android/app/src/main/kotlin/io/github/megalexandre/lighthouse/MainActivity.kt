package io.github.megalexandre.lighthouse

import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // lib/api/client_info.dart: the name the server shows for this device.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lighthouse/device")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "name" -> result.success(deviceName())
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
}
