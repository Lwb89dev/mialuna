package app.mialuna.social

import android.graphics.Bitmap
import android.media.MediaMetadataRetriever
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.concurrent.Executors

/**
 * Video frame extraction with the platform's own decoder, no extra
 * dependency. Works on local files and https URLs (only the bytes needed
 * for the frame are fetched for streamable MP4 files).
 */
object MediaBridge {
    private const val CHANNEL = "app.mialuna.social/media"
    private val executor = Executors.newFixedThreadPool(2)
    private val main = Handler(Looper.getMainLooper())

    fun register(engine: FlutterEngine) {
        MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != "videoThumbnail") {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                val source = call.argument<String>("source")
                val maxWidth = call.argument<Int>("maxWidth") ?: 720
                val timeMs = (call.argument<Number>("timeMs") ?: 500).toLong()
                if (source.isNullOrEmpty()) {
                    result.error("ARGS", "source missing", null)
                    return@setMethodCallHandler
                }
                executor.execute {
                    try {
                        val out = extract(source, maxWidth, timeMs)
                        main.post { result.success(out) }
                    } catch (e: Exception) {
                        main.post { result.error("THUMB", e.message, null) }
                    }
                }
            }
    }

    private fun extract(source: String, maxWidth: Int, timeMs: Long): Map<String, Any> {
        val retriever = MediaMetadataRetriever()
        try {
            if (source.startsWith("https://") || source.startsWith("http://")) {
                retriever.setDataSource(source, HashMap())
            } else {
                retriever.setDataSource(source)
            }
            val durationMs = retriever
                .extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                ?.toLongOrNull() ?: 0L
            val at = if (durationMs in 1..timeMs) 0L else timeMs
            var frame = retriever.getFrameAtTime(
                at * 1000, MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
            ) ?: retriever.getFrameAtTime(
                -1, MediaMetadataRetriever.OPTION_CLOSEST_SYNC,
            ) ?: throw IllegalStateException("no frame")
            if (frame.width > maxWidth) {
                val h = (frame.height.toLong() * maxWidth / frame.width).toInt()
                frame = Bitmap.createScaledBitmap(frame, maxWidth, h, true)
            }
            val bytes = ByteArrayOutputStream().also {
                frame.compress(Bitmap.CompressFormat.JPEG, 82, it)
            }.toByteArray()
            return mapOf(
                "bytes" to bytes,
                "width" to frame.width,
                "height" to frame.height,
                "durationMs" to durationMs,
            )
        } finally {
            retriever.release()
        }
    }
}
