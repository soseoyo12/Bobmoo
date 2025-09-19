# 밥묵자 (Bobmoo)

대학교 식단 정보를 확인할 수 있는 Flutter 기반 Android 앱입니다.

## 주요 기능

- 📅 **날짜별 식단 조회**: 원하는 날짜의 식단 정보를 확인할 수 있습니다
- 🍽️ **시간대별 메뉴**: 아침, 점심, 저녁으로 구분된 메뉴 정보
- 🏫 **다양한 식당**: 대학교 내 여러 식당의 메뉴를 한 번에 확인
- ⏰ **운영시간 표시**: 각 식당의 운영시간 정보 제공
- 📱 **위젯 지원**: 홈 화면에서 바로 식단 정보 확인 가능

## 기술 스택

- **Flutter** 3.9.2+
- **Dart** 3.9.2+
- **HTTP** API 통신
- **SharedPreferences** 로컬 데이터 저장
- **Home Widget** 위젯 기능

## 프로젝트 구조

```
lib/
├── main.dart                 # 앱 진입점
├── models/                   # 데이터 모델
│   ├── menu_model.dart      # 메뉴 관련 모델
│   └── meal_by_cafeteria.dart
├── screens/                  # 화면
│   ├── home_screen.dart     # 메인 화면
│   └── settings_screen.dart # 설정 화면
├── services/                 # API 서비스
│   └── menu_service.dart
├── utils/                    # 유틸리티
│   └── hours_parser.dart
└── widgets/                  # 재사용 가능한 위젯
    ├── cafeteria_card.dart
    ├── cafeteria_menu_column.dart
    ├── meal_item_row.dart
    ├── open_status_badge.dart
    └── time_grouped_card.dart
```
