import 'package:bobmoo/models/meal_by_cafeteria.dart';
import 'package:bobmoo/widgets/cafeteria_menu_column.dart';
import 'package:flutter/material.dart';

class TimeGroupedCard extends StatelessWidget {
  final String title;
  final List<MealByCafeteria> mealData;

  const TimeGroupedCard({
    super.key,
    required this.title,
    required this.mealData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 섹션 제목 (예: "점심")
            Text(
              title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            // 각 식당별 메뉴 목록
            ...mealData.map((data) => CafeteriaMenuColumn(data: data)),
          ],
        ),
      ),
    );
  }
}
