package com.example.practicalogin

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.provider.Settings

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.practicalogin/security"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "isUsbDebuggingEnabled") {
                val adbEnabled = Settings.Global.getInt(contentResolver, Settings.Global.ADB_ENABLED, 0) != 0
                result.success(adbEnabled)
            } else {
                result.notImplemented()
            }
        }
    }
}
