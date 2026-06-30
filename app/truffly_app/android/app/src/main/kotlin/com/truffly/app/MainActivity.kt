package com.truffly.app

import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.truffly.app/notification_settings",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "areNotificationsEnabled" -> {
                    result.success(areNotificationsEnabled())
                }
                "openNotificationSettings" -> {
                    openNotificationSettings()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun areNotificationsEnabled(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) return true

        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        return notificationManager.areNotificationsEnabled()
    }

    private fun openNotificationSettings() {
        val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
            }
        } else {
            Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS).apply {
                data = Uri.parse("package:$packageName")
            }
        }

        startActivity(intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK))
    }
}
