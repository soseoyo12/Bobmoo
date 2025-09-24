package com.hwoo.bobmoo
import HomeWidgetGlanceStateDefinition
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONObject
import java.util.Calendar

// 1. Glance 위젯의 로직과 상태 관리를 담당
class MealGlanceWidget : GlanceAppWidget() {
    // Needed for Updating
    override val stateDefinition = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            // SharedPreferences에서 데이터 읽기
            val widgetData = HomeWidgetPlugin.getData(context)
            val data = widgetData.getString("widgetData", null)
    
            // 현재 시간 가져오기
            Calendar.getInstance().get(Calendar.DATE)

            var mealType = "식사 정보"
            var courseName = "데이터 없음"
            var menus = "앱을 실행하여 데이터를 동기화 해주세요."

            if (data != null) {
                try {
                    val json = JSONObject(data)
                    mealType = json.getString("mealType")
                    courseName = json.getString("courseName")
                    menus = json.getString("menus").replace(", ", "\n")
                } catch (e: Exception) {
                    menus = "데이터 포맷 오류"
                }
            }

            // 2. UI를 그리는 Composable 함수 호출
            MealWidgetContent(mealType, courseName, menus)
        }
    }

    // 3. UI의 모양을 정의하는 Composable 함수 (Flutter의 Widget과 유사)
    @Composable
    fun MealWidgetContent(mealType: String, courseName: String, menus: String) {
        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(R.color.gray)
                .padding(12.dp)
        ) {
            Text(
                text = mealType,
                style = TextStyle(fontWeight = FontWeight.Bold, fontSize = 18.sp),
            )
            Text(
                text = courseName,
                style = TextStyle(fontSize = 14.sp, color = androidx.glance.color.ColorProvider(
                    Color.Gray, Color.Red)),
                modifier = GlanceModifier.padding(top = 4.dp)
            )
            Text(
                text = menus,
                style = TextStyle(fontSize = 12.sp, color = androidx.glance.color.ColorProvider(
                    Color.Blue, Color.Red)),
                modifier = GlanceModifier.padding(top = 8.dp)
            )

        }
    }
}



// 4. 시스템 이벤트를 수신하는 Receiver
class MealGlanceWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = MealGlanceWidget()
}