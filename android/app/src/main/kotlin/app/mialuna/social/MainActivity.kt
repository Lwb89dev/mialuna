package app.mialuna.social

import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

/**
 * NIP-55 bridge to Amber (or any compatible external signer).
 * The private key never enters this process: signing requests are
 * delegated to the signer app via intents.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "app.mialuna.social/amber"
    private val signerPackage = "com.greenart7c3.nostrsigner"
    private var pendingResult: MethodChannel.Result? = null
    private val reqGetPubkey = 5501
    private val reqSignEvent = 5502

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "isSignerAvailable" -> result.success(isSignerInstalled())
                    "getPublicKey" -> launchSigner(result, reqGetPubkey, "get_public_key", null)
                    "signEvent" -> {
                        val eventJson = JSONObject().apply {
                            put("id", call.argument<String>("id"))
                            put("pubkey", call.argument<String>("pubkey"))
                            put("created_at", call.argument<Int>("created_at"))
                            put("kind", call.argument<Int>("kind"))
                            put("tags", JSONArray(call.argument<List<List<String>>>("tags")))
                            put("content", call.argument<String>("content"))
                        }
                        launchSigner(result, reqSignEvent, "sign_event", eventJson.toString())
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

    private fun launchSigner(
        result: MethodChannel.Result,
        requestCode: Int,
        type: String,
        eventJson: String?
    ) {
        if (pendingResult != null) {
            result.error("BUSY", "Another signer request is in progress", null)
            return
        }
        if (!isSignerInstalled()) {
            result.error("NO_SIGNER", "Amber is not installed", null)
            return
        }
        val intent = Intent(Intent.ACTION_VIEW).apply {
            setPackage(signerPackage)
            // NIP-55: payload in the nostrsigner: URI, type as extra.
            data = android.net.Uri.parse("nostrsigner:${eventJson ?: ""}")
            putExtra("type", type)
        }
        pendingResult = result
        try {
            startActivityForResult(intent, requestCode)
        } catch (e: Exception) {
            pendingResult = null
            result.error("LAUNCH_FAILED", e.message, null)
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        val result = pendingResult ?: return
        pendingResult = null
        if (resultCode != Activity.RESULT_OK || data == null) {
            result.error("REJECTED", "Request rejected in signer", null)
            return
        }
        when (requestCode) {
            reqGetPubkey -> {
                val pubkey = data.getStringExtra("result")
                if (pubkey.isNullOrEmpty()) {
                    result.error("EMPTY", "Signer returned no public key", null)
                } else {
                    result.success(pubkey)
                }
            }
            reqSignEvent -> {
                val signature = data.getStringExtra("signature")
                if (signature.isNullOrEmpty()) {
                    result.error("EMPTY", "Signer returned no signature", null)
                } else {
                    result.success(signature)
                }
            }
        }
    }
}
