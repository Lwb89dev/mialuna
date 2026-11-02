package app.mialuna.social

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * System notifications for what arrives while the app is running in the
 * background (reactions, comments, zaps, followers, private messages).
 *
 * Nothing here talks to the network or to any push service: Dart decides what
 * deserves a notification and hands over the text. Private messages arrive
 * with a generic public version, so their sender and text stay off the lock
 * screen.
 */
object NotifyBridge {
    private const val CHANNEL = "app.mialuna.social/notify"
    const val EXTRA_ROUTE = "mialuna_route"

    private var channel: MethodChannel? = null
    private var launchRoute: String? = null
    private lateinit var appContext: Context

    fun register(context: Context, engine: FlutterEngine, launchIntent: Intent?) {
        appContext = context.applicationContext
        launchRoute = launchIntent?.getStringExtra(EXTRA_ROUTE)
        val ch = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        channel = ch
        ch.setMethodCallHandler { call, result ->
            when (call.method) {
                "canNotify" -> result.success(canNotify())
                "show" -> result.success(show(call.arguments as Map<*, *>))
                "cancelAll" -> {
                    manager().cancelAll()
                    result.success(null)
                }
                // The screen a tapped notification asked for, once.
                "initialRoute" -> {
                    result.success(launchRoute)
                    launchRoute = null
                }
                else -> result.notImplemented()
            }
        }
    }

    /** A notification was tapped while the app was already running. */
    fun onNewIntent(intent: Intent) {
        val route = intent.getStringExtra(EXTRA_ROUTE) ?: return
        val ch = channel
        if (ch == null) {
            launchRoute = route
        } else {
            ch.invokeMethod("route", route)
        }
    }

    private fun manager(): NotificationManager =
        appContext.getSystemService(NotificationManager::class.java)

    private fun canNotify(): Boolean = manager().areNotificationsEnabled()

    private fun show(args: Map<*, *>): Boolean {
        val nm = manager()
        if (!nm.areNotificationsEnabled()) return false
        val channelId = args["channel"] as String
        val id = (args["id"] as Number).toInt()
        val title = args["title"] as String
        val body = args["body"] as String
        val publicTitle = args["publicTitle"] as? String ?: title
        val publicBody = args["publicBody"] as? String ?: body
        val route = args["route"] as? String
        ensureChannel(nm, channelId, args["channelName"] as String)

        val open = Intent(appContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_SINGLE_TOP or Intent.FLAG_ACTIVITY_CLEAR_TOP
            if (route != null) putExtra(EXTRA_ROUTE, route)
        }
        val tap = PendingIntent.getActivity(
            appContext, id, open,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
        )
        nm.notify(id, build(channelId, title, body, tap, publicTitle, publicBody))
        return true
    }

    private fun builder(channelId: String): Notification.Builder =
        if (Build.VERSION.SDK_INT >= 26) Notification.Builder(appContext, channelId)
        else @Suppress("DEPRECATION") Notification.Builder(appContext)

    private fun build(
        channelId: String,
        title: String,
        body: String,
        tap: PendingIntent,
        publicTitle: String,
        publicBody: String,
    ): Notification {
        val lockScreen = builder(channelId)
            .setSmallIcon(R.drawable.ic_stat_mialuna)
            .setContentTitle(publicTitle)
            .setContentText(publicBody)
            .build()
        return builder(channelId)
            .setSmallIcon(R.drawable.ic_stat_mialuna)
            .setContentTitle(title)
            .setContentText(body)
            .setStyle(Notification.BigTextStyle().bigText(body))
            .setContentIntent(tap)
            .setAutoCancel(true)
            .setOnlyAlertOnce(true)
            .setGroup(channelId)
            .setVisibility(Notification.VISIBILITY_PRIVATE)
            .setPublicVersion(lockScreen)
            .build()
    }

    private fun ensureChannel(nm: NotificationManager, id: String, name: String) {
        if (Build.VERSION.SDK_INT < 26) return
        val importance = if (id == "messages") {
            NotificationManager.IMPORTANCE_HIGH
        } else {
            NotificationManager.IMPORTANCE_DEFAULT
        }
        val channel = NotificationChannel(id, name, importance).apply {
            setShowBadge(true)
            lockscreenVisibility = Notification.VISIBILITY_PRIVATE
        }
        nm.createNotificationChannel(channel)
    }
}
