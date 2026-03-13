package com.example.media_dedup_poc

import android.graphics.BitmapFactory
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.imageembedder.ImageEmbedder
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "media_dedup_poc/image_embedder"
        private const val MODEL_ASSET_PATH = "models/mobilenet_v3_small.tflite"
    }

    private val executor = Executors.newSingleThreadExecutor()
    private var imageEmbedder: ImageEmbedder? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "getImageEmbedding" -> {
                        val imagePath = call.argument<String>("imagePath")
                        if (imagePath.isNullOrBlank()) {
                            result.error("INVALID_ARGUMENT", "imagePath is required", null)
                            return@setMethodCallHandler
                        }

                        executor.execute {
                            try {
                                val embedding = embedImage(imagePath)
                                runOnUiThread { result.success(embedding) }
                            } catch (exception: Exception) {
                                runOnUiThread {
                                    result.error(
                                        "EMBEDDING_ERROR",
                                        exception.message,
                                        null
                                    )
                                }
                            }
                        }
                    }

                    "isModelReady" -> {
                        result.success(isModelReady())
                    }

                    else -> result.notImplemented()
                }
            }
    }

    @Synchronized
    private fun getImageEmbedder(): ImageEmbedder {
        if (imageEmbedder == null) {
            val baseOptions = BaseOptions.builder()
                .setModelAssetPath(MODEL_ASSET_PATH)
                .build()

            val options = ImageEmbedder.ImageEmbedderOptions.builder()
                .setBaseOptions(baseOptions)
                .setRunningMode(RunningMode.IMAGE)
                .build()

            imageEmbedder = ImageEmbedder.createFromOptions(this, options)
        }
        return imageEmbedder!!
    }

    private fun isModelReady(): Boolean {
        return try {
            getImageEmbedder()
            true
        } catch (_: Exception) {
            false
        }
    }

    private fun embedImage(imagePath: String): List<Float> {
        val bitmap = BitmapFactory.decodeFile(imagePath)
            ?: throw IllegalStateException("Unable to decode image at $imagePath")
        val mpImage = BitmapImageBuilder(bitmap).build()
        val result = getImageEmbedder().embed(mpImage)
        val embedding = result.embeddings().firstOrNull()?.floatEmbedding()
            ?: throw IllegalStateException("No embedding returned for $imagePath")
        return embedding.toList()
    }

    override fun onDestroy() {
        imageEmbedder?.close()
        executor.shutdown()
        super.onDestroy()
    }
}
