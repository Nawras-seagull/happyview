package com.nawras.happyview

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "happy_view/wallpaper")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setWallpaper" -> {
                        val imageBytes = call.argument<ByteArray>("imageBytes")
                        if (imageBytes == null) {
                            result.error("INVALID_ARGUMENT", "Wallpaper data is required.", null)
                            return@setMethodCallHandler
                        }

                        try {
                            val tempFile = java.io.File.createTempFile("wallpaper", ".jpg", cacheDir)
                            tempFile.outputStream().use { it.write(imageBytes) }

                            val contentUri = FileProvider.getUriForFile(
                                this,
                                "$packageName.fileprovider",
                                tempFile
                            )

                            val intent = Intent(Intent.ACTION_ATTACH_DATA).apply {
                                addCategory(Intent.CATEGORY_DEFAULT)
                                setDataAndType(contentUri, "image/*")
                                putExtra("mimeType", "image/*")
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            }

                            startActivity(Intent.createChooser(intent, "Set wallpaper"))
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("WALLPAPER_ERROR", e.message ?: "Failed to open wallpaper picker", null)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
