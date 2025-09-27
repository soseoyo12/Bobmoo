package com.hwoo.bobmoo

import android.content.Context
import androidx.glance.GlanceId
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Calendar

class MealGlanceWidget : GlanceAppWidget() {
    // 데이터 새로고침을 위해 stateDefinition 주석처리
    // override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            // SharedPreferences에서 데이터 읽기
            val widgetData = HomeWidgetPlugin.getData(context)
            val data = widgetData.getString("widgetData", null)
            val now = Calendar.getInstance()

            val mealInfo = MealWidgetDataParser.parseMealInfo(data, now)

            MealWidgetContent(
                context = context,
                periodLabel = mealInfo.periodLabel,
                hoursLabel = mealInfo.hoursLabel,
                cafeteriaName = mealInfo.cafeteriaName,
                courses = mealInfo.courses,
                status = mealInfo.status
            )
        }
    }
}