import 'package:bobmoo/models/meal_by_cafeteria.dart';
import 'package:bobmoo/models/menu_model.dart';
import 'package:bobmoo/widgets/meal_item_row.dart';
import 'package:flutter/material.dart';

class CafeteriaMenuColumn extends StatelessWidget {
  final MealByCafeteria data;
  final String mealType;
  const CafeteriaMenuColumn({
    super.key,
    required this.data,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 식당 이름
        Row(
          children: [
            Text(
              data.cafeteriaName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                _hoursTextForMealType(data.hours, mealType),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        // 이 식당의 메뉴들 (기존에 만들었던 MealItemRow 재활용)
        ...data.meals.map((meal) => MealItemRow(meal: meal)),
      ],
    );
  }
}

String _hoursTextForMealType(Hours hours, String mealType) {
  return switch (mealType) {
    '아침' => hours.breakfast.isNotEmpty ? '(${hours.breakfast})' : '',
    '점심' => hours.lunch.isNotEmpty ? '(${hours.lunch})' : '',
    '저녁' => hours.dinner.isNotEmpty ? '(${hours.dinner})' : '',
    // '_' 는 default와 같습니다.
    _ => '', // 아이콘이 없는 경우 빈 공간
  };
}
