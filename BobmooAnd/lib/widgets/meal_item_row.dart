import 'package:bobmoo/models/menu_model.dart';
import 'package:flutter/material.dart';

class MealItemRow extends StatelessWidget {
  final MealItem meal;
  const MealItemRow({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 코스 (A, B, C...)
          SizedBox(
            width: 15, // 너비를 고정하여 정렬을 맞춤
            child: Text(
              meal.course,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
          // 2. 메뉴 이름 (가장 넓은 공간 차지)
          Expanded(
            child: Text(
              meal.mainMenu,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
