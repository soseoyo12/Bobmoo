import 'package:bobmoo/constants/app_colors.dart';
import 'package:bobmoo/models/meal_by_cafeteria.dart';
import 'package:bobmoo/widgets/cafeteria_menu_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TimeGroupedCard extends StatelessWidget {
  final String title;
  final List<MealByCafeteria> mealData;
  final DateTime selectedDate;

  const TimeGroupedCard({
    super.key,
    required this.title,
    required this.mealData,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: 0,
      ),
      shadowColor: Colors.black,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 제목 (예: "점심")
            Row(
              children: [
                _getIconForMeal(title), // 위에서 만든 함수로 아이콘 가져오기
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            // 각 식당별 메뉴 목록
            ListView.separated(
              padding: EdgeInsets.only(top: 12),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mealData.length,
              itemBuilder: (BuildContext context, int index) {
                // 각 인덱스에 해당하는 식당 메뉴 위젯을 반환
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: CafeteriaMenuColumn(
                    data: mealData[index],
                    mealType: title,
                    selectedDate: selectedDate,
                  ),
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                // 각 아이템 사이에 들어갈 구분선 위젯을 반환
                return Divider(
                  height: 10.h,
                  thickness: 1.5,
                  color: AppColors.grayDividerColor,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// 아이콘을 결정하는 함수
Widget _getIconForMeal(String title) {
  // => 를 사용해 바로 위젯을 반환합니다.
  final icon = switch (title) {
    '아침' => SvgPicture.asset(
      'assets/icons/wb_twilight.svg',
      width: 24,
      height: 24,
    ),
    '점심' => const Icon(Icons.wb_sunny_outlined, size: 24),
    '저녁' => const Icon(Icons.dark_mode_outlined, size: 24),
    // '_' 는 default와 같습니다.
    _ => const SizedBox.shrink(), // 아이콘이 없는 경우 빈 공간
  };

  return Padding(
    padding: const EdgeInsets.only(right: 4.0),
    child: icon,
  );
}
