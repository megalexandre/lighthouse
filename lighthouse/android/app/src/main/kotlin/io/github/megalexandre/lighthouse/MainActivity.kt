package io.github.megalexandre.lighthouse

import android.app.PendingIntent
import android.app.PictureInPictureParams
import android.app.RemoteAction
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.graphics.drawable.Icon
import android.media.AudioManager
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.util.Base64
import android.util.Rational
import android.view.KeyEvent
import android.view.WindowManager
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.security.KeyStore
import kotlin.concurrent.thread

// AudioServiceActivity: the engine it gives is the one audio_service plays
// music with, which must outlive the activity. With a plain FlutterActivity
// the plugin would start a second one.
private const val FLOATING_ACTION = "io.github.megalexandre.lighthouse.FLOATING"

class MainActivity : AudioServiceActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The player's floating window (lib/core/floating_window.dart):
        // picture in picture.
        floating = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lighthouse/floating")
            .apply { setMethodCallHandler(::onFloatingCall) }
        // "name": the name the server shows for this device
        // (lib/api/client_info.dart). "certificates": the file mpv checks
        // HTTPS servers with (lib/core/system_certificates.dart). The
        // rest: the player's swipes (lib/core/device_levels.dart), levels
        // from 0 to 1.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lighthouse/device")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "name" -> result.success(deviceName())
                    "certificates" -> writeCertificates(result)
                    "volume" -> result.success(volume())
                    "setVolume" -> {
                        setVolume(call.arguments as Double)
                        result.success(null)
                    }
                    "brightness" -> result.success(brightness())
                    "setBrightness" -> {
                        setBrightness(call.arguments as Double?)
                        result.success(null)
                    }
                    "holdVolumeKeys" -> {
                        volumeKeysHeld = call.arguments as Boolean
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private val audio: AudioManager
        get() = getSystemService(Context.AUDIO_SERVICE) as AudioManager

    // The media stream: the one the phone's keys change while something
    // plays.
    private fun volume(): Double {
        val max = audio.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        return if (max == 0) 0.0
        else audio.getStreamVolume(AudioManager.STREAM_MUSIC).toDouble() / max
    }

    // No flags: the app shows its own level, not the system's slider.
    private fun setVolume(level: Double) {
        val max = audio.getStreamMaxVolume(AudioManager.STREAM_MUSIC)
        val steps = Math.round(level.coerceIn(0.0, 1.0) * max).toInt()
        try {
            audio.setStreamVolume(AudioManager.STREAM_MUSIC, steps, 0)
        } catch (e: SecurityException) {
            // Do Not Disturb may forbid it: the volume stays as it was.
        }
    }

    // The window's own brightness, or else the screen's setting (0..255 on
    // most phones; an estimate where the scale differs).
    private fun brightness(): Double {
        val own = window.attributes.screenBrightness
        if (own >= 0) return own.toDouble()
        val system = Settings.System.getInt(
            contentResolver, Settings.System.SCREEN_BRIGHTNESS, 128,
        )
        return (system / 255.0).coerceIn(0.0, 1.0)
    }

    // This window only, never the system setting; null: the screen's own.
    private fun setBrightness(level: Double?) {
        val attributes = window.attributes
        attributes.screenBrightness = level?.coerceIn(0.0, 1.0)?.toFloat()
            ?: WindowManager.LayoutParams.BRIGHTNESS_OVERRIDE_NONE
        window.attributes = attributes
    }

    // The player is locked: the volume keys do nothing, for the system
    // (its slider) and for Flutter alike.
    private var volumeKeysHeld = false

    override fun dispatchKeyEvent(event: KeyEvent): Boolean {
        if (volumeKeysHeld) {
            when (event.keyCode) {
                KeyEvent.KEYCODE_VOLUME_UP,
                KeyEvent.KEYCODE_VOLUME_DOWN,
                KeyEvent.KEYCODE_VOLUME_MUTE -> return true
            }
        }
        return super.dispatchKeyEvent(event)
    }

    // ---- Picture in picture ------------------------------------------------

    private var floating: MethodChannel? = null

    // What the player offers while a video is open (null: none): the
    // picture's shape, whether it plays, and the buttons' labels.
    private var offer: Map<*, *>? = null

    // Between onStop and onStart: closing the floating window stops the
    // activity before it says it left picture in picture.
    private var stopped = false

    private val pipSupported: Boolean
        get() = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O &&
            packageManager.hasSystemFeature(PackageManager.FEATURE_PICTURE_IN_PICTURE)

    private fun onFloatingCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "supported" -> result.success(pipSupported)
            "enter" -> result.success(enterFloating((call.arguments as Number).toDouble()))
            "leave" -> {
                // An app cannot grow its PiP window back: it goes away,
                // the app to the background, as when the user closes it.
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N && isInPictureInPictureMode) {
                    moveTaskToBack(false)
                }
                result.success(null)
            }
            "offer" -> {
                offer = call.arguments as Map<*, *>?
                updateFloating()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun send(event: String) {
        floating?.invokeMethod("event", event)
    }

    private fun enterFloating(aspectRatio: Double? = null): Boolean {
        if (!pipSupported || Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        return try {
            enterPictureInPictureMode(floatingParams(aspectRatio))
        } catch (e: IllegalStateException) {
            // The user turned picture in picture off for the app.
            false
        } catch (e: IllegalArgumentException) {
            false
        }
    }

    // The system's buttons: −10 s, play / pause, +10 s; on Android 12+ it
    // floats by itself when the user goes Home while the video plays.
    @androidx.annotation.RequiresApi(Build.VERSION_CODES.O)
    private fun floatingParams(aspectRatio: Double? = null): PictureInPictureParams {
        val offer = offer
        val ratio = aspectRatio ?: (offer?.get("aspectRatio") as Number?)?.toDouble() ?: (16.0 / 9)
        // Android takes from 1:2.39 to 2.39:1, and nothing else.
        val clamped = ratio.coerceIn(1 / 2.39 + 0.001, 2.39 - 0.001)
        val builder = PictureInPictureParams.Builder()
            .setAspectRatio(Rational((clamped * 10000).toInt(), 10000))
        if (offer != null) {
            val playing = offer["playing"] == true
            builder.setActions(
                listOf(
                    action("seekBack", android.R.drawable.ic_media_rew, offer["back10"]),
                    if (playing) action("playPause", android.R.drawable.ic_media_pause, offer["pause"])
                    else action("playPause", android.R.drawable.ic_media_play, offer["play"]),
                    action("seekForward", android.R.drawable.ic_media_ff, offer["forward10"]),
                ),
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                builder.setAutoEnterEnabled(playing)
            }
        } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            builder.setAutoEnterEnabled(false)
        }
        return builder.build()
    }

    @androidx.annotation.RequiresApi(Build.VERSION_CODES.O)
    private fun action(name: String, icon: Int, label: Any?): RemoteAction {
        val intent = Intent(FLOATING_ACTION).setPackage(packageName).putExtra("action", name)
        val pending = PendingIntent.getBroadcast(
            this,
            name.hashCode(),
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT,
        )
        val text = label as String? ?: name
        return RemoteAction(Icon.createWithResource(this, icon), text, text, pending)
    }

    private fun updateFloating() {
        if (!pipSupported || Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        try {
            setPictureInPictureParams(floatingParams())
        } catch (e: IllegalArgumentException) {
            // A shape Android refuses: it floats as it did.
        } catch (e: IllegalStateException) {
        }
    }

    // Before Android 12 there is no auto-enter: the user leaving is the cue.
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S && offer?.get("playing") == true) {
            enterFloating()
        }
    }

    override fun onPictureInPictureModeChanged(isInPictureInPictureMode: Boolean, newConfig: Configuration) {
        super.onPictureInPictureModeChanged(isInPictureInPictureMode, newConfig)
        send(
            when {
                isInPictureInPictureMode -> "entered"
                stopped -> "closed"
                else -> "expanded"
            },
        )
    }

    private val floatingActions = object : BroadcastReceiver() {
        override fun onReceive(context: Context, intent: Intent) {
            intent.getStringExtra("action")?.let(::send)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val filter = IntentFilter(FLOATING_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(floatingActions, filter, Context.RECEIVER_NOT_EXPORTED)
        } else {
            @Suppress("UnspecifiedRegisterReceiverFlag")
            registerReceiver(floatingActions, filter)
        }
    }

    override fun onDestroy() {
        unregisterReceiver(floatingActions)
        super.onDestroy()
    }

    override fun onStart() {
        super.onStart()
        stopped = false
    }

    override fun onStop() {
        stopped = true
        super.onStop()
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
