package com.example.flutter_app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "your_channel_name"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setAccelerationSamplingPeriod") {
                val period = call.arguments as Int
                // Implement your logic here
                result.success(null) // Return success
            } else {
                result.notImplemented()
            }
        }
    }
}
