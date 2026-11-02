package app.mialuna.social

import android.app.Activity
import android.view.WindowManager
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Marks the window secure while a private screen is open (private messages,
 * the close-friends list, close-friends stories): Android then blocks
 * screenshots and screen recording of it and shows a blank thumbnail in the
 * app switcher, so nothing private is left in the recents list.
 */
object WindowBridge {
    private const val CHANNEL = "app.mialuna.social/window"

    fun register(activity: Activity, engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "setSecure") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val secure = call.arguments as? Boolean ?: false
                activity.runOnUiThread {
                    if (secure) {
                        activity.window.setFlags(
                            WindowManager.LayoutParams.FLAG_SECURE,
                            WindowManager.LayoutParams.FLAG_SECURE,
                        )
                    } else {
                        activity.window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    }
                    result.success(null)
                }
            }
    }
}
