package com.hwoo.bobmoo

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.*
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.actionStartActivity
import java.text.SimpleDateFormat
import java.util.*

// --- 1. 재사용 컴포넌트: 최상단 헤더 ---
@Composable
fun WidgetHeader(currentTime: String) {
    Row(
        modifier = GlanceModifier.fillMaxWidth(),
        verticalAlignment = Alignment.Vertical.CenterVertically
    ) {
        Text(
            text = currentTime,
            style = TextStyle(
                fontSize = 12.sp,
                color = androidx.glance.color.ColorProvider(Color.Gray, Color.Gray)
            )
        )
    }
}

// --- 2. 재사용 컴포넌트: "아침", "점심" 등 시간대 헤더 ---
@Composable
fun MealPeriodHeader(periodLabel: String, globalStatus: String) {
    // 상태별 색상을 정의하는 데이터 클래스
    data class StatusColors(val background: Color, val text: Color)

    // when을 사용하여 상태별 색상을 결정합니다.
    val statusColors = when (globalStatus) {
        "운영중" -> StatusColors(background = Color(0xFF4D89B2), text = Color.White) // 파란 계열
        "운영전" -> StatusColors(background = Color(0xFF4D89B2), text = Color.White) // 회색 계열
        "운영종료" -> StatusColors(background = Color(0xFFC95353), text = Color.White) // 빨간 계열
        else -> null // 상태 텍스트가 없으면 null 반환
    }

    // Row를 사용하여 시간대와 상태 배지를 가로로 배치합니다.
    Row(
        modifier = GlanceModifier.fillMaxWidth().padding(top = 8.dp),
        verticalAlignment = Alignment.Vertical.CenterVertically
    ) {
        // "아침", "점심" 등 시간대 텍스트
        Text(
            text = periodLabel,
            style = TextStyle(
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold
            )
        )
        Spacer(modifier = GlanceModifier.defaultWeight())

        // 상태 배지 (Chip UI)
        // statusColors가 null이 아닐 때만 (상태 텍스트가 있을 때만) 배지를 표시합니다.
        if (statusColors != null) {
            Box(
                modifier = GlanceModifier
                    .background(statusColors.background)
                    .padding(horizontal = 8.dp, vertical = 4.dp)
                    .cornerRadius(8.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = globalStatus,
                    style = TextStyle(
                        color = androidx.glance.color.ColorProvider(
                            statusColors.text,
                            statusColors.text
                        ),
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold
                    )
                )
            }
        }
    }
    Spacer(modifier = GlanceModifier.height(12.dp))
}

// --- 3. 재사용 컴포넌트: 식당 정보 세로 칼럼 ---
@Composable
fun CafeteriaColumn(mealInfo: MealInfo) {
    Column(
        modifier = GlanceModifier.fillMaxHeight(),
        horizontalAlignment = Alignment.Horizontal.Start
    ) {
        Text(
            text = mealInfo.cafeteriaName,
            style = TextStyle(fontSize = 14.sp, fontWeight = FontWeight.Bold),
            maxLines = 1
        )
        Spacer(modifier = GlanceModifier.height(2.dp))
        Text(
            text = "(${mealInfo.hoursLabel})",
            style = TextStyle(
                fontSize = 12.sp,
                color = androidx.glance.color.ColorProvider(Color.Gray, Color.Gray)
            ),
            maxLines = 1
        )
        Spacer(modifier = GlanceModifier.height(4.dp))
        // 메뉴 리스트
        mealInfo.courses.forEach { line ->
            Text(
                text = line,
                style = TextStyle(fontSize = 13.sp),
                modifier = GlanceModifier.padding(top = 2.dp),
                maxLines = 2 // 메뉴가 너무 길 경우 최대 2줄로 제한
            )
        }
    }
}

@Composable
fun AllCafeteriasWidgetContent(context: Context, mealInfos: List<MealInfo>) {
    val sdf = SimpleDateFormat("M월 d일 EEEE HH:mm", Locale.KOREAN)
    val currentTimeString = sdf.format(Date())

    // "운영중"인 식당이 하나라도 있는지 확인하여 전체 상태를 결정
    val globalStatus =
        mealInfos.find { it.status == "운영중" }?.status ?: mealInfos.firstOrNull()?.status ?: ""
    val periodLabel = mealInfos.firstOrNull()?.periodLabel ?: "정보 없음"

    Column(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(Color.White)
            .padding(16.dp)
            .clickable(onClick = actionStartActivity<MainActivity>(context)),
    ) {
        WidgetHeader(currentTime = currentTimeString)
        MealPeriodHeader(globalStatus = globalStatus, periodLabel = periodLabel)

        Row(
            modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
            verticalAlignment = Alignment.Vertical.Top
        ) {
            // 각 식당 정보에 대해 루프를 돕니다.
            mealInfos.forEachIndexed { index, mealInfo ->
                Box(
                    modifier = GlanceModifier.defaultWeight().fillMaxHeight(),
                    contentAlignment = Alignment.TopStart
                ) {
                    CafeteriaColumn(mealInfo = mealInfo)
                }

                if (index < mealInfos.size - 1) {
                    // 컨텐츠 뒤에 항상 세로선을 추가합니다.
                    VerticalSeparator()
                }
            }
        }
    }
}

/**
 * 세로 구분선을 그리는 Composable 함수 (재사용을 위해 분리)
 */
@Composable
private fun VerticalSeparator() {
    Spacer(modifier = GlanceModifier.width(8.dp))
    Spacer(
        modifier = GlanceModifier.width(1.dp).height(100.dp)
            .background(Color(0xFFE0E0E0))
    )
    Spacer(modifier = GlanceModifier.width(8.dp))
}