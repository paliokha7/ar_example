package com.example.ar_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Register ARCore plugin
        flutterEngine
            .platformViewsController
            .registry
            .registerViewFactory(
                "arcore_flutter_plugin/view",
                ARCoreViewFactory(flutterEngine.dartExecutor.binaryMessenger)
            )
    }
} 