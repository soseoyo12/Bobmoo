package com.hwoo.bobmoo

import android.Manifest
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.annotation.RequiresPermission
import androidx.core.content.getSystemService
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.Calendar

class AllCafeteriasGlanceWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = AllCafeteriasGlanceWidget()

    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        scheduleUpdate(context)
    }

    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        context.getSystemService<AlarmManager>()?.cancel(createBroadcastPendingIntent(context))
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        val action = intent.action
        if (action == WIDGET_UPDATE_ACTION || action == android.appwidget.AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            CoroutineScope(Dispatchers.Main).launch {
                val glanceIds =
                    GlanceAppWidgetManager(context).getGlanceIds(glanceAppWidget.javaClass)
                glanceIds.forEach { glanceId ->
                    glanceAppWidget.update(context, glanceId)
                }
            }
            scheduleUpdate(context)
        }
    }

    @RequiresPermission(Manifest.permission.SCHEDULE_EXACT_ALARM)
    private fun scheduleUpdate(context: Context) {
        val alarmManager = context.getSystemService<AlarmManager>()
        if (alarmManager == null) {
            android.util.Log.w("WidgetSchedule", "AlarmManager not available.")
            return
        }
        val pendingIntent = createBroadcastPendingIntent(context)
        val nextMinute = Calendar.getInstance().apply {
            add(Calendar.MINUTE, 1)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            if (alarmManager.canScheduleExactAlarms()) {
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    nextMinute.timeInMillis,
                    pendingIntent
                )
            } else {
                android.util.Log.w(
                    "WidgetSchedule",
                    "Cannot schedule exact alarms, permission denied."
                )
            }
        } else {
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                nextMinute.timeInMillis,
                pendingIntent
            )
        }
    }

    private fun createBroadcastPendingIntent(context: Context): PendingIntent {
        val intent = Intent(context, this::class.java).setAction(WIDGET_UPDATE_ACTION)
        return PendingIntent.getBroadcast(
            context,
            0,
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }

    companion object {
        private const val WIDGET_UPDATE_ACTION = "com.hwoo.bobmoo.action.WIDGET_UPDATE"
    }
}