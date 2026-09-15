package com.smartvision.faskhanista

import android.app.Notification
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.os.Build
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import com.example.live_activities.LiveActivityManager
import kotlin.math.max

class CustomLiveActivityManager(context: Context) : LiveActivityManager(context) {
    private val appContext = context.applicationContext

    private val contentIntent = PendingIntent.getActivity(
        appContext,
        200,
        Intent(appContext, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_REORDER_TO_FRONT
        },
        PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )

    private val remoteViews = RemoteViews(appContext.packageName, R.layout.live_activity)

    private fun parseLong(value: Any?): Long? = when (value) {
        is Int -> value.toLong()
        is Long -> value
        is Double -> value.toLong()
        is Float -> value.toLong()
        is String -> value.toLongOrNull()
        else -> null
    }

    private fun firstNonBlankString(
        data: Map<String, Any>,
        keys: List<String>,
        fallback: String
    ): String {
        for (key in keys) {
            val value = (data[key] as? String)?.trim()
            if (!value.isNullOrEmpty()) return value
        }
        return fallback
    }

    private fun firstLong(
        data: Map<String, Any>,
        keys: List<String>
    ): Long? {
        for (key in keys) {
            val value = parseLong(data[key])
            if (value != null) return value
        }
        return null
    }

    private fun updateViews(data: Map<String, Any>) {
        val restaurantName = firstNonBlankString(
            data,
            listOf("restaurantName", "restaurant_name"),
            "FaskhaNinja"
        )
        val status = firstNonBlankString(
            data,
            listOf("order_status", "orderStatus", "status"),
            "Preparing"
        )
        val driverName = firstNonBlankString(
            data,
            listOf("driverName", "driver_name"),
            ""
        )
        val deliveryTimeMs = firstLong(
            data,
            listOf("deliveryTime", "delivery_time")
        )

        remoteViews.setTextViewText(R.id.restaurant_name, restaurantName)
        remoteViews.setTextViewText(R.id.order_status, status)

        if (driverName.isNotEmpty()) {
            remoteViews.setViewVisibility(R.id.driver_row, View.VISIBLE)
            remoteViews.setTextViewText(R.id.driver_name, driverName)
        } else {
            remoteViews.setViewVisibility(R.id.driver_row, View.GONE)
        }

        if (deliveryTimeMs != null) {
            val remainingMs = max(0L, deliveryTimeMs - System.currentTimeMillis())
            val baseTime = SystemClock.elapsedRealtime() + remainingMs
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                remoteViews.setChronometerCountDown(R.id.delivery_timer, true)
            }
            remoteViews.setChronometer(R.id.delivery_timer, baseTime, null, true)
            remoteViews.setViewVisibility(R.id.eta_row, View.VISIBLE)
        } else {
            remoteViews.setViewVisibility(R.id.eta_row, View.GONE)
        }

        val logoPath = data["app_logo"] as? String

        if (logoPath == "app_logo") {
             // If key is exactly "app_logo", load from drawable resources
             val resId = appContext.resources.getIdentifier("app_logo", "drawable", appContext.packageName)
             if (resId != 0) {
                 remoteViews.setImageViewResource(R.id.app_logo, resId)
             } else {
                 // Fallback to launcher icon if app_logo drawable not found
                  remoteViews.setImageViewResource(R.id.app_logo, R.mipmap.launcher_icon)
             }
        } else {
            // Otherwise treat as a file path (for dynamic images)
            val logoBitmap = logoPath?.let { BitmapFactory.decodeFile(it) }
            if (logoBitmap != null) {
                remoteViews.setImageViewBitmap(R.id.app_logo, logoBitmap)
            } else {
                remoteViews.setImageViewResource(R.id.app_logo, R.mipmap.launcher_icon)
            }
        }
    }

    override suspend fun buildNotification(
        notification: Notification.Builder,
        event: String,
        data: Map<String, Any>
    ): Notification {
        updateViews(data)

        return notification
            .setSmallIcon(R.mipmap.launcher_icon)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setContentIntent(contentIntent)
            .setCustomContentView(remoteViews)
            .setCustomBigContentView(remoteViews)
            .setStyle(Notification.DecoratedCustomViewStyle())
            .setVisibility(Notification.VISIBILITY_PUBLIC)
            .setCategory(Notification.CATEGORY_SERVICE)
            .build()
    }
}
