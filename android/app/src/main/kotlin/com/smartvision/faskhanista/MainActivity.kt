package com.smartvision.faskhanista

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import com.example.live_activities.LiveActivityManagerHolder
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)

        hideNavigationBar()

        // Create notification channel on app launch
        createNotificationChannel()
    }

    override fun onPostResume() {
        super.onPostResume()
        hideNavigationBar()
    }

    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        if (hasFocus) {
            hideNavigationBar()
        }
    }

    private fun hideNavigationBar() {
        WindowInsetsControllerCompat(window, window.decorView).apply {
            hide(WindowInsetsCompat.Type.navigationBars())
            systemBarsBehavior =
                WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        LiveActivityManagerHolder.instance = CustomLiveActivityManager(this)
    }

    private fun createNotificationChannel() {
        // Define the channel ID and name
        val channelId = "faskhaninja_channel_id"
        val channelName = "FaskhaNinja Notifications"
        val channelDescription = "This channel is used for FaskhaNinja app notifications"

        // Only create the channel if it doesn't already exist (Android Oreo and above)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(channelId, channelName, importance)
            channel.description = channelDescription
            val notificationManager: NotificationManager = getSystemService(NotificationManager::class.java)
            notificationManager.createNotificationChannel(channel)
        }
    }
}
