import 'package:bobmoo/models/meal_by_cafeteria.dart';
import 'package:bobmoo/widgets/meal_item_row.dart';
import 'package:flutter/material.dart';

class CafeteriaMenuColumn extends StatelessWidget {
  final MealByCafeteria data;
  const CafeteriaMenuColumn({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 식당 이름
        Text(
          data.cafeteriaName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        // 이 식당의 메뉴들 (기존에 만들었던 MealItemRow 재활용)
        ...data.meals.map((meal) => MealItemRow(meal: meal)),
      ],
    );
  }
}
