import 'package:bobmoo/models/menu_model.dart';
import 'package:bobmoo/widgets/meal_item_row.dart';
import 'package:flutter/material.dart';

class CafeteriaCard extends StatelessWidget {
  final Cafeteria cafeteria;
  const CafeteriaCard({super.key, required this.cafeteria});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cafeteria.name,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // TODO: 운영시간 표시 (cafeteria.hours)
            const SizedBox(height: 16),
            MealTypeCard(title: '아침', meals: cafeteria.meals.breakfast),
            MealTypeCard(title: '점심', meals: cafeteria.meals.lunch),
            MealTypeCard(title: '저녁', meals: cafeteria.meals.dinner),
          ],
        ),
      ),
    );
  }
}

class MealTypeCard extends StatelessWidget {
  final String title;
  final List<MealItem> meals;
  const MealTypeCard({super.key, required this.title, required this.meals});

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return const SizedBox.shrink(); // 메뉴 없으면 아무것도 안 그림
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        // TODO: meals 리스트를 순회하며 각 메뉴(MealItem) 표시하기
        ...meals.map((meal) => MealItemRow(meal: meal)),
      ],
    );
  }
}
