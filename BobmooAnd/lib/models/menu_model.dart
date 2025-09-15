// 1. 최상위 응답 모델
class MenuResponse {
  final String date;
  final String school;
  final List<Cafeteria> cafeterias;

  MenuResponse({
    required this.date,
    required this.school,
    required this.cafeterias,
  });
}

// 2. 식당 모델
class Cafeteria {
  final String name;
  final Hours hours;
  final Meals meals;

  Cafeteria({
    required this.name,
    required this.hours,
    required this.meals,
  });
}

// 3. 운영 시간 모델
class Hours {
  final String breakfast;
  final String lunch;
  final String dinner;

  Hours({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });
}

// 4a. 식사 모델 (추천)
class Meals {
  final List<MealItem> breakfast;
  final List<MealItem> lunch;
  final List<MealItem> dinner;

  Meals({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });
}

// 4b. 개별 메뉴 아이템 모델
class MealItem {
  final String course;
  final String mainMenu;
  final int price;

  MealItem({
    required this.course,
    required this.mainMenu,
    required this.price,
  });
}
