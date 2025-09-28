package com.hwoo.bobmoo

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceModifier
import androidx.glance.action.clickable
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.layout.width
import es.antonborri.home_widget.actionStartActivity

@Composable
fun AllCafeteriasWidgetContent(context: Context, mealInfos: List<MealInfo>) {
    // Row를 사용하여 내부 아이템들을 가로로 배치합니다.
    Row(
        modifier = GlanceModifier
            .fillMaxSize() // 위젯 공간을 가득 채웁니다.
            .background(Color.White)
            .padding(1.dp) // 전체적인 패딩을 적용합니다.
            .clickable(onClick = actionStartActivity<MainActivity>(context)),
        verticalAlignment = Alignment.Vertical.CenterVertically,
        horizontalAlignment = Alignment.Horizontal.CenterHorizontally
    ) {
        // mealInfos 리스트에 데이터가 없을 경우를 대비합니다.
        if (mealInfos.isEmpty()) {
            // MealWidgetContent를 재사용하여 기본/에러 메시지를 표시합니다.
            MealWidgetContent(
                context = context,
                periodLabel = "정보 없음",
                hoursLabel = "",
                cafeteriaName = "표시할 식당 정보가 없습니다",
                courses = listOf("앱에서 설정을 확인해주세요."),
                status = ""
            )
        } else {
            // 리스트에 있는 각 식당 정보를 가로로 나열합니다.
            mealInfos.forEachIndexed { index, mealInfo ->
                // Box가 각 식당 UI의 영역을 담당합니다.
                // defaultWeight()는 각 식당이 가로 공간을 균등하게 나눠 갖도록 만듭니다.
                Box(
                    modifier = GlanceModifier.defaultWeight().fillMaxHeight()
                        .padding(horizontal = 2.dp),
                    contentAlignment = Alignment.TopStart
                ) {
                    // **핵심: 기존 MealWidgetContent를 완벽하게 재사용합니다!**
                    MealWidgetContent(
                        context = context,
                        periodLabel = mealInfo.periodLabel,
                        hoursLabel = mealInfo.hoursLabel,
                        cafeteriaName = mealInfo.cafeteriaName,
                        courses = mealInfo.courses,
                        status = mealInfo.status
                    )
                }

                // 마지막 아이템이 아닐 경우에만 오른쪽에 공간을 추가합니다.
                if (index < mealInfos.size - 1) {
                    Spacer(modifier = GlanceModifier.width(1.dp))
                }
            }
        }
    }
}