package com.hwoo.bobmoo
import HomeWidgetGlanceStateDefinition
import HomeWidgetGlanceWidgetReceiver
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.compose.ui.graphics.Color
import androidx.glance.layout.Alignment
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.actionStartActivity
import org.json.JSONArray
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Locale

// 1. Glance 위젯의 로직과 상태 관리를 담당
class MealGlanceWidget : GlanceAppWidget() {
    // Needed for Updating
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            // SharedPreferences에서 데이터 읽기
            val widgetData = HomeWidgetPlugin.getData(context)
            val data = widgetData.getString("widgetData", null)

            val now = Calendar.getInstance()

            var headerDateTime = formattedNow(now)
            var periodLabel = "식사 정보"
            var hoursLabel = "--:--"
            var cafeteriaName = "식당 정보 없음"
            var courses: List<String> = listOf("앱을 실행하여 데이터를 동기화 해주세요.")
            var status = "" // 운영전/운영중/운영종료

            if (data != null) {
                try {
                    val root = JSONObject(data)
                    val date = root.optString("date")
                    cafeteriaName = root.optString("cafeteriaName", cafeteriaName)

                    val hours = root.optJSONObject("hours")
                    val breakfastHours = hours?.optString("breakfast") ?: ""
                    val lunchHours = hours?.optString("lunch") ?: ""
                    val dinnerHours = hours?.optString("dinner") ?: ""

                    val meals = root.optJSONObject("meals")
                    val breakfast = meals?.optJSONArray("breakfast") ?: JSONArray()
                    val lunch = meals?.optJSONArray("lunch") ?: JSONArray()
                    val dinner = meals?.optJSONArray("dinner") ?: JSONArray()

                    val (target, targetStatus) = selectTargetPeriod(now, breakfastHours, lunchHours, dinnerHours)
                    status = targetStatus

                    when (target) {
                        MealPeriod.BREAKFAST -> {
                            periodLabel = "아침"
                            hoursLabel = breakfastHours
                            courses = mapCourses(breakfast)
                        }
                        MealPeriod.LUNCH -> {
                            periodLabel = "점심"
                            hoursLabel = lunchHours
                            courses = mapCourses(lunch)
                        }
                        MealPeriod.DINNER -> {
                            periodLabel = "저녁"
                            hoursLabel = dinnerHours
                            courses = mapCourses(dinner)
                        }
                    }

                    if (date.isNotEmpty()) {
                        headerDateTime = "$date ${formattedTime(now)}"
                    }
                } catch (e: Exception) {
                    periodLabel = "데이터 오류"
                    hoursLabel = "--:--"
                    cafeteriaName = ""
                    courses = listOf("데이터 포맷 오류")
                    status = ""
                }
            }

            MealWidgetContent(
                context = context,
                headerDateTime = headerDateTime,
                periodLabel = periodLabel,
                hoursLabel = hoursLabel,
                cafeteriaName = cafeteriaName,
                courses = courses,
                status = status,
            )
        }
    }

    // 3. UI
    @Composable
    fun MealWidgetContent(
        context: Context,
        headerDateTime: String,
        periodLabel: String,
        hoursLabel: String,
        cafeteriaName: String,
        courses: List<String>,
        status: String,
    ) {
        Box(
            modifier =
                GlanceModifier.background(Color.White)
                    .padding(16.dp)
                    .clickable(onClick = actionStartActivity<MainActivity>(context))) {
            Column(
                modifier = GlanceModifier.fillMaxSize(),
                verticalAlignment = Alignment.Vertical.Top,
                horizontalAlignment = Alignment.Horizontal.Start,
            ) {
                // 날짜 + 현재 시간
                Text(text = headerDateTime, style = TextStyle(fontSize = 12.sp))

                // 시간대 + 운영시간(작게)
                Row(modifier = GlanceModifier.padding(top = 6.dp)) {
                    Text(
                        text = periodLabel,
                        style = TextStyle(fontWeight = FontWeight.Bold, fontSize = 18.sp)
                    )
                    Text(
                        text = "  $hoursLabel",
                        style = TextStyle(fontSize = 12.sp)
                    )
                }

                // 텍스트 색깔
                // androidx.glance.color.ColorProvider(Color.Gray, Color.Red)
                // 첫번째는 일반(라이트) 일때 색상 두번째는 다크모드일때 색상

                // 식당 이름
                Text(
                    text = cafeteriaName,
                    style = TextStyle(fontSize = 14.sp),
                    modifier = GlanceModifier.padding(top = 6.dp)
                )

                // 코스 + 메뉴들 (여러 줄)
                courses.forEach { line ->
                    Text(
                        text = line,
                        style = TextStyle(fontSize = 12.sp),
                        modifier = GlanceModifier.padding(top = 4.dp)
                    )
                }

                // 오른쪽 아래 상태는 Glance 제약상 간단히 마지막 줄로 강조
                Text(
                    text = status,
                    style = TextStyle(fontWeight = FontWeight.Bold, fontSize = 12.sp),
                    modifier = GlanceModifier.padding(top = 8.dp)
                )
            }
        }
    }

    private fun formattedNow(now: Calendar): String {
        val sdf = SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.getDefault())
        return sdf.format(now.time)
    }

    private fun formattedTime(now: Calendar): String {
        val sdf = SimpleDateFormat("HH:mm", Locale.getDefault())
        return sdf.format(now.time)
    }

    private enum class MealPeriod { BREAKFAST, LUNCH, DINNER }

    private fun selectTargetPeriod(
        now: Calendar,
        breakfastHours: String,
        lunchHours: String,
        dinnerHours: String,
    ): Pair<MealPeriod, String> {
        val b = parseHoursToToday(now, breakfastHours)
        val l = parseHoursToToday(now, lunchHours)
        val d = parseHoursToToday(now, dinnerHours)

        return when {
            now.before(b.first) -> MealPeriod.BREAKFAST to "운영전"
            now.after(b.first) && now.before(b.second) -> MealPeriod.BREAKFAST to "운영중"
            now.after(b.second) && now.before(l.first) -> MealPeriod.LUNCH to "운영전"
            now.after(l.first) && now.before(l.second) -> MealPeriod.LUNCH to "운영중"
            now.after(l.second) && now.before(d.first) -> MealPeriod.DINNER to "운영전"
            now.after(d.first) && now.before(d.second) -> MealPeriod.DINNER to "운영중"
            else -> MealPeriod.DINNER to "운영종료"
        }
    }

    private fun parseHoursToToday(base: Calendar, hours: String): Pair<Calendar, Calendar> {
        // hours: "HH:mm-HH:mm"
        val startEnd = hours.split("-")
        val start = (base.clone() as Calendar)
        val end = (base.clone() as Calendar)
        fun apply(timeStr: String, cal: Calendar) {
            try {
                val parts = timeStr.trim().split(":")
                cal.set(Calendar.HOUR_OF_DAY, parts[0].toInt())
                cal.set(Calendar.MINUTE, parts[1].toInt())
                cal.set(Calendar.SECOND, 0)
                cal.set(Calendar.MILLISECOND, 0)
            } catch (_: Exception) {
                // fallback 00:00
                cal.set(Calendar.HOUR_OF_DAY, 0)
                cal.set(Calendar.MINUTE, 0)
                cal.set(Calendar.SECOND, 0)
                cal.set(Calendar.MILLISECOND, 0)
            }
        }
        if (startEnd.size == 2) {
            apply(startEnd[0], start)
            apply(startEnd[1], end)
        } else {
            // invalid -> 00:00-00:00
            apply("00:00", start)
            apply("00:00", end)
        }
        return start to end
    }

    private fun mapCourses(mealArray: JSONArray): List<String> {
        val courses = mutableListOf<String>()
        for (i in 0 until mealArray.length()) {
            try {
                val meal = mealArray.getJSONObject(i)
                val course = meal.optString("course", "")
                val mainMenu = meal.optString("mainMenu", "")
                if (course.isNotEmpty() && mainMenu.isNotEmpty()) {
                    courses.add("$course $mainMenu")
                }
            } catch (e: Exception) {
                // 개별 메뉴 파싱 실패 시 무시
            }
        }
        return if (courses.isEmpty()) listOf("메뉴 정보 없음") else courses
    }
}

// 4. 시스템 이벤트를 수신하는 Receiver
class MealGlanceWidgetReceiver : HomeWidgetGlanceWidgetReceiver<MealGlanceWidget>() {
    override val glanceAppWidget = MealGlanceWidget()
}