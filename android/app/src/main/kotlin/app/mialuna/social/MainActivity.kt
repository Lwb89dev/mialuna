package app.mialuna.social

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.concurrent.Executors

/**
 * NIP-55 bridge to Amber (or any compatible external signer).
 * The private key never enters this process: signing and encryption requests
 * are delegated to the signer app, first through its content provider (silent,
 * possible once the user chose "remember" in the signer) and then through
 * intents (the signer shows its approval screen).
 */
class MainActivity : FlutterActivity() {
    private val channelName = "app.mialuna.social/amber"
    private val signerPackage = "com.greenart7c3.nostrsigner"
    private var pendingResult: MethodChannel.Result? = null
    private var pendingKey: String = "result"
    private val requestCode = 5501
    private val resolverExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MediaBridge.register(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                val currentUser = call.argument<String>("current_user")
                val currentUserNpub = call.argument<String>("current_user_npub")
                when (call.method) {
                    "isSignerAvailable" -> result.success(isSignerInstalled())
                    "getPublicKey" -> launchSigner(
                        result, "get_public_key", "", emptyMap(), "result",
                    )
                    "signEvent" -> {
                        val eventJson = JSONObject().apply {
                            put("id", call.argument<String>("id"))
                            put("pubkey", call.argument<String>("pubkey"))
                            put("created_at", call.argument<Int>("created_at"))
                            put("kind", call.argument<Int>("kind"))
                            put("tags", JSONArray(call.argument<List<List<String>>>("tags")))
                            put("content", call.argument<String>("content"))
                        }.toString()
                        request(
                            result, "SIGN_EVENT", "sign_event", eventJson,
                            arrayOf(eventJson, "", currentUserNpub ?: ""),
                            mapOf("current_user" to (currentUser ?: "")),
                            "signature",
                        )
                    }
                    "nip44Encrypt", "nip44Decrypt" -> {
                        val encrypt = call.method == "nip44Encrypt"
                        val text = call.argument<String>("text") ?: ""
                        val peer = call.argument<String>("pubkey") ?: ""
                        request(
                            result,
                            if (encrypt) "NIP44_ENCRYPT" else "NIP44_DECRYPT",
                            if (encrypt) "nip44_encrypt" else "nip44_decrypt",
                            text,
                            arrayOf(text, peer, currentUserNpub ?: ""),
                            mapOf("pubkey" to peer, "current_user" to (currentUser ?: "")),
                            "result",
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun isSignerInstalled(): Boolean = try {
        packageManager.getPackageInfo(signerPackage, 0)
        true
    } catch (e: PackageManager.NameNotFoundException) {
        false
    }

    /** Tries the silent content provider, then falls back to the intent flow. */
    private fun request(
        result: MethodChannel.Result,
        provider: String,
        type: String,
        payload: String,
        projection: Array<String>,
        extras: Map<String, String>,
        resultKey: String,
    ) {
        if (!isSignerInstalled()) {
            result.error("NO_SIGNER", "Amber non è installato", null)
            return
        }
        resolverExecutor.execute {
            val answer = queryProvider(provider, projection)
            mainHandler.post {
                when {
                    answer == null -> launchSigner(result, type, payload, extras, resultKey)
                    answer["rejected"] != null ->
                        result.error("REJECTED", "Richiesta rifiutata in Amber", null)
                    else -> {
                        val value = answer[resultKey] ?: answer["result"]
                        if (value.isNullOrEmpty()) {
                            launchSigner(result, type, payload, extras, resultKey)
                        } else {
                            result.success(value)
                        }
                    }
                }
            }
        }
    }

    /** Returns the cursor's columns, or null when the provider cannot answer
     *  without user interaction. */
    private fun queryProvider(method: String, projection: Array<String>): Map<String, String>? {
        return try {
            val uri = Uri.parse("content://$signerPackage.$method")
            contentResolver.query(uri, projection, null, null, null)?.use { cursor ->
                if (cursor.getColumnIndex("rejected") >= 0) {
                    return@use mapOf("rejected" to "true")
                }
                if (!cursor.moveToFirst()) return@use null
                val out = HashMap<String, String>()
                for (name in arrayOf("result", "signature", "event")) {
                    val i = cursor.getColumnIndex(name)
                    if (i >= 0) cursor.getString(i)?.let { out[name] = it }
                }
                if (out.isEmpty()) null else out
            }
        } catch (e: Exception) {
            null
        }
    }

    private fun launchSigner(
        result: MethodChannel.Result,
        type: String,
        payload: String,
        extras: Map<String, String>,
        resultKey: String,
    ) {
        if (pendingResult != null) {
            result.error("BUSY", "Un'altra richiesta al firmatario è in corso", null)
            return
        }
        if (!isSignerInstalled()) {
            result.error("NO_SIGNER", "Amber non è installato", null)
            return
        }
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setPackage(signerPackage)
            // NIP-55: payload in the nostrsigner: URI, type and params as extras.
            data = Uri.parse("nostrsigner:$payload")
            putExtra("type", type)
            for ((k, v) in extras) if (v.isNotEmpty()) putExtra(k, v)
        }
        pendingResult = result
        pendingKey = resultKey
        try {
            startActivityForResult(intent, requestCode)
        } catch (e: Exception) {
            pendingResult = null
            result.error("LAUNCH_FAILED", e.message, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != this.requestCode) return
        val result = pendingResult ?: return
        pendingResult = null
        if (resultCode != Activity.RESULT_OK || data == null ||
            data.getBooleanExtra("rejected", false)
        ) {
            result.error("REJECTED", "Richiesta rifiutata in Amber", null)
            return
        }
        val value = data.getStringExtra(pendingKey) ?: data.getStringExtra("result")
        if (value.isNullOrEmpty()) {
            result.error("EMPTY", "Il firmatario non ha restituito nulla", null)
        } else {
            result.success(value)
        }
    }
}
