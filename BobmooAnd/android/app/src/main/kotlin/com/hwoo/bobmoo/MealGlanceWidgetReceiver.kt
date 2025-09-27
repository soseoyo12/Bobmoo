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

class MealGlanceWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = MealGlanceWidget()

    // 위젯이 처음 화면에 추가될 때 호출됩니다.
    override fun onEnabled(context: Context) {
        super.onEnabled(context)
        scheduleUpdate(context) // 최초 업데이트 예약을 시작합니다.
    }

    // 마지막 위젯이 화면에서 제거될 때 호출됩니다.
    override fun onDisabled(context: Context) {
        super.onDisabled(context)
        // 예약된 알람을 취소하여 배터리 낭비를 막습니다.
        context.getSystemService<AlarmManager>()?.cancel(createBroadcastPendingIntent(context))
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        // 수신된 Intent의 Action을 확인합니다.
        val action = intent.action

        // 우리가 예약한 알람이거나, 시스템의 공식 업데이트 요청일 때만 실행합니다.
        if (action == WIDGET_UPDATE_ACTION || action == android.appwidget.AppWidgetManager.ACTION_APPWIDGET_UPDATE) {
            // 위젯을 업데이트합니다.
            CoroutineScope(Dispatchers.Main).launch {
                val glanceIds =
                    GlanceAppWidgetManager(context).getGlanceIds(glanceAppWidget.javaClass)
                glanceIds.forEach { glanceId ->
                    glanceAppWidget.update(context, glanceId)
                }
            }

            // 다음 1분 뒤 업데이트를 다시 예약합니다. (가장 중요!)
            scheduleUpdate(context)
        }
    }

    /**
     * 다음 정각 분에 업데이트를 예약하는 함수
     */
    @RequiresPermission(Manifest.permission.SCHEDULE_EXACT_ALARM)
    private fun scheduleUpdate(context: Context) {
        val alarmManager = context.getSystemService<AlarmManager>()
        if (alarmManager == null) {
            // 알람 매니저가 없으면 아무것도 할 수 없으므로 함수 종료
            android.util.Log.w("WidgetSchedule", "AlarmManager not available.")
            return
        }

        val pendingIntent = createBroadcastPendingIntent(context)

        // 다음 정각 분으로 시간을 설정합니다.
        val nextMinute = Calendar.getInstance().apply {
            add(Calendar.MINUTE, 1)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }

        // 안드로이드 12 (S, API 31) 이상 버전에서는 권한을 직접 확인해야 합니다.
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {
            if (alarmManager.canScheduleExactAlarms()) {
                // 권한이 있을 때만 정확한 알람을 설정합니다.
                alarmManager.setExactAndAllowWhileIdle(
                    AlarmManager.RTC_WAKEUP,
                    nextMinute.timeInMillis,
                    pendingIntent
                )
                android.util.Log.d("WidgetSchedule", "Exact alarm scheduled.")
            } else {
                // 권한이 없을 경우, 사용자에게 알리거나 대체 방안을 찾아야 합니다.
                // 여기서는 일단 로그만 남깁니다.
                android.util.Log.w(
                    "WidgetSchedule",
                    "Cannot schedule exact alarms, permission denied."
                )
            }
        } else {
            // 안드로이드 11 (R, API 30) 이하 버전에서는 이전처럼 바로 설정합니다.
            alarmManager.setExactAndAllowWhileIdle(
                AlarmManager.RTC_WAKEUP,
                nextMinute.timeInMillis,
                pendingIntent
            )
            android.util.Log.d("WidgetSchedule", "Exact alarm scheduled on older Android.")
        }
    }

    /**
     * 업데이트를 위한 PendingIntent를 생성하는 함수
     */
    private fun createBroadcastPendingIntent(context: Context): PendingIntent {
        // Intent에 고유한 Action을 설정합니다.
        val intent = Intent(context, this::class.java).setAction(WIDGET_UPDATE_ACTION)
        return PendingIntent.getBroadcast(
            context,
            0, // requestCode
            intent,
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        )
    }

    // 고유 Action 문자열을 정의하는 companion object 추가
    companion object {
        private const val WIDGET_UPDATE_ACTION = "com.hwoo.bobmoo.action.WIDGET_UPDATE"
    }
}