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
              // TODO: 메인 메뉴 한줄로 하고 ...을 뒤에 붙히도록 할지 고민
              // maxLines: 1,
              // overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(
            width: 4,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              "${meal.price}원",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
