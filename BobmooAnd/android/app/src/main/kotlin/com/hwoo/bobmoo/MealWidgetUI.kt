package com.hwoo.bobmoo

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.actionStartActivity
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun MealWidgetContent(
    context: Context,
    periodLabel: String,
    hoursLabel: String,
    cafeteriaName: String,
    courses: List<String>,
    status: String,
) {
    val sdf = SimpleDateFormat("M월 d일 EEEE HH:mm", Locale.KOREAN)
    val currentTimeString = sdf.format(Date())

    Box(
        modifier = GlanceModifier
            .background(Color.White)
            .padding(12.dp)
            .clickable(onClick = actionStartActivity<MainActivity>(context))
    ) {
        Column(
            modifier = GlanceModifier.fillMaxSize(),
            verticalAlignment = Alignment.Vertical.Top,
            horizontalAlignment = Alignment.Horizontal.Start,
        ) {
            // 날짜 + 현재 시간
            Text(text = currentTimeString, style = TextStyle(fontSize = 10.sp))

            // 시간대 + 운영시간(작게)
            Row(modifier = GlanceModifier.padding(top = 6.dp)) {
                Text(
                    text = periodLabel,
                    style = TextStyle(fontWeight = FontWeight.Bold, fontSize = 18.sp)
                )
                Text(
                    text = "  ($hoursLabel)",
                    style = TextStyle(fontSize = 10.sp)
                )
            }

            // 텍스트 색깔
            // androidx.glance.color.ColorProvider(Color.Gray, Color.Red)
            // 첫번째는 일반(라이트) 일때 색상 두번째는 다크모드일때 색상


            Box(modifier = GlanceModifier.padding(top = 4.dp)) {}

            // 식당 이름
            Text(
                text = cafeteriaName,
                style = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.Bold),
                modifier = GlanceModifier.padding(top = 6.dp)
            )

            // 코스 + 메뉴들 (여러 줄)
            courses.forEach { line ->
                Text(
                    text = line,
                    style = TextStyle(fontSize = 13.sp),
                    modifier = GlanceModifier.padding(top = 4.dp)
                )
            }

            // 오른쪽 아래 운영 상태
            Text(
                text = status,
                style = TextStyle(fontWeight = FontWeight.Bold, fontSize = 14.sp),
                modifier = GlanceModifier.padding(top = 12.dp)
            )
        }
    }
}