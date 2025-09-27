package com.hwoo.bobmoo

import org.json.JSONArray
import org.json.JSONObject
import java.util.Calendar

// 위젯에 표시될 정보를 담는 데이터 클래스
data class MealInfo(
    val periodLabel: String,
    val hoursLabel: String,
    val cafeteriaName: String,
    val courses: List<String>,
    val status: String
)

object MealWidgetDataParser {

    private enum class MealPeriod { BREAKFAST, LUNCH, DINNER }

    fun parseMealInfo(data: String?, now: Calendar): MealInfo {
        if (data == null) {
            return MealInfo(
                periodLabel = "식사 정보",
                hoursLabel = "--:--",
                cafeteriaName = "식당 정보 없음",
                courses = listOf("앱을 실행하여 데이터를 동기화 해주세요."),
                status = ""
            )
        }

        try {
            val root = JSONObject(data)
            val cafeteriaName = root.optString("cafeteriaName", "식당 정보 없음")

            val hours = root.optJSONObject("hours")
            val breakfastHours = hours?.optString("breakfast") ?: ""
            val lunchHours = hours?.optString("lunch") ?: ""
            val dinnerHours = hours?.optString("dinner") ?: ""

            val meals = root.optJSONObject("meals")
            val breakfast = meals?.optJSONArray("breakfast") ?: JSONArray()
            val lunch = meals?.optJSONArray("lunch") ?: JSONArray()
            val dinner = meals?.optJSONArray("dinner") ?: JSONArray()

            val (target, targetStatus) = selectTargetPeriod(
                now,
                breakfastHours,
                lunchHours,
                dinnerHours
            )

            val periodLabel: String
            val hoursLabel: String
            val courses: List<String>

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

            return MealInfo(
                periodLabel,
                hoursLabel,
                cafeteriaName,
                courses,
                targetStatus
            )

        } catch (e: Exception) {
            return MealInfo(
                periodLabel = "데이터 오류",
                hoursLabel = "--:--",
                cafeteriaName = "",
                courses = listOf("데이터 포맷 오류"),
                status = ""
            )
        }
    }

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