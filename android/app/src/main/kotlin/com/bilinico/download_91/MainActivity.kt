package com.bilinico.download_91

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // 注册 PiP 插件
        PipPlugin.registerWith(flutterEngine.dartExecutor.binaryMessenger, this)
    }
    
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        // 用户按 Home 键时，可以通知 Flutter 进入 PiP 模式
        // 由 Flutter 端处理
    }
}
