import 'package:bobmoo/models/menu_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MealItemRow extends StatelessWidget {
  final MealItem meal;
  const MealItemRow({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    // 숫자를 통화 형식(,)으로 바꿔주기 위한 포맷터
    final currencyFormat = NumberFormat.currency(locale: 'ko_KR', symbol: '');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. 코스 (A, B, C...)
          SizedBox(
            width: 40, // 너비를 고정하여 정렬을 맞춤
            child: Text(
              meal.course,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          // 2. 메뉴 이름 (가장 넓은 공간 차지)
          Expanded(
            child: Text(
              meal.mainMenu,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // 3. 가격
          SizedBox(
            width: 60, // 너비를 고정하여 정렬을 맞춤
            child: Text(
              '${currencyFormat.format(meal.price)}원',
              textAlign: TextAlign.right, // 오른쪽 정렬
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
