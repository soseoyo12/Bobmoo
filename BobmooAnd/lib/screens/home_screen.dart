import 'package:bobmoo/collections/meal_collection.dart';
import 'package:bobmoo/collections/restaurant_collection.dart';
import 'package:bobmoo/locator.dart';
import 'package:bobmoo/models/meal_by_cafeteria.dart';
import 'package:bobmoo/models/menu_model.dart';
import 'package:bobmoo/repositories/meal_repository.dart';
import 'package:bobmoo/widgets/time_grouped_card.dart';
import 'package:bobmoo/utils/hours_parser.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 1. 상태변구 변경: Future 객체로 데이터와 로딩 상태를 한번에 관리
  final MealRepository _repository = locator<MealRepository>();
  late Future<List<Meal>> _mealFuture;

  /// 선택한 날짜 저장할 상태 변수
  DateTime _selectedDate = DateTime.now();

  /// Stale 데이터 알림 메시지
  String? _staleDataMessage;

  /// 화면이 처음 나타날 때 데이터 불러오기
  @override
  void initState() {
    super.initState();
    _loadMeals(); // 초기 데이터 로드
  }

  // 2. 데이터 로드 함수 변경: Repository를 사용하도록 수정
  /// Repository를 이용하여 데이터 로드
  void _loadMeals() {
    _staleDataMessage = null; // 메시지 초기화
    _mealFuture = _repository.getMealsForDate(_selectedDate).catchError((e) {
      // StaleDataException을 별도로 처리
      if (e is StaleDataException) {
        setState(() {
          _staleDataMessage = e.message;
        });
        // Stale 데이터를 Future의 성공 결과로 반환하여 UI에 표시
        return e.staleData;
      }
      // 그 외 에러는 그대로 다시 던짐
      throw e;
    });
    setState(() {}); // Future가 변경되었음을 UI에 알림
  }

  // 3. 새로고침 함수 추가
  /// Pull-to-Refresh(당겨서 새로고침)을 위한 새로고침 함수
  Future<void> _refreshMeals() async {
    _staleDataMessage = null;
    setState(() {
      _mealFuture = _repository.forceRefreshMeals(_selectedDate);
    });
  }

  // 4. 날짜 선택 함수 수정
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _selectedDate) {
      _selectedDate = picked;
      _loadMeals(); // 새 날짜로 데이터 로드
    }
  }

  // 5. 데이터 구조 변환 함수: `List<Meal>` -> `Map<String, List<MealByCafeteria>>`
  /// 기존 UI 위젯과 호환시키기 위한 데이터 변환 로직
  /// 모든 A, B코스들을 아침, 점심, 저녁으로 분류해서 반환함.
  Map<String, List<MealByCafeteria>> _groupMeals(List<Meal> meals) {
    final Map<String, MealByCafeteria> tempMap = {};

    for (var meal in meals) {
      // isarLink를 통해 Restaurant 정보 로드
      final restaurant = meal.restaurant.value;
      if (restaurant == null) continue;

      // 키 생성 (예: "생활관식당_점심")
      final key = '${restaurant.name}_${meal.mealTime.name}';

      // 특정 시간대(점심)을 담을 공간(바구니)가 있는지 확인하고 없으면 빈 바구니를 만듬
      if (!tempMap.containsKey(key)) {
        tempMap[key] = MealByCafeteria(
          cafeteriaName: restaurant.name,
          // MealByCafeteria 모델에 맞게 데이터 채우기
          hours: _createHoursFromRestaurant(restaurant),
          meals: [],
        );
      }
      // MealItem 모델로 변환하여 추가
      tempMap[key]!.meals.add(
        MealItem(course: meal.course, mainMenu: meal.menu, price: meal.price),
      );
    }

    // 최종적으로 시간대별로 그룹화
    final Map<String, List<MealByCafeteria>> grouped = {
      '아침': [],
      '점심': [],
      '저녁': [],
    };
    tempMap.forEach((key, value) {
      if (key.endsWith('breakfast')) grouped['아침']!.add(value);
      if (key.endsWith('lunch')) grouped['점심']!.add(value);
      if (key.endsWith('dinner')) grouped['저녁']!.add(value);
    });

    return grouped;
  }

  /// Restaurant 객체로부터 Hours 객체를 생성하는 헬퍼 함수
  Hours _createHoursFromRestaurant(Restaurant r) {
    return Hours(
      breakfast: r.breakfastHours,
      lunch: r.lunchHours,
      dinner: r.dinnerHours,
    );
  }

  // 6. 기존 시간 정렬 로직을 새 데이터 구조에 맞게 수정

  /// 선택된 날짜의 운영시간(Hours)을 사용해 동적 경계를 계산한 뒤 섹션 순서를 반환합니다.
  /// 기준:
  /// - now < 아침 종료최대 → [아침, 점심, 저녁]
  /// - 아침 종료최대 ≤ now < 점심 종료최대 → [점심, 저녁, 아침]
  /// - 그 외 → [저녁, 아침, 점심]
  List<String> _orderedMealTypesByDynamicHours(
    Map<String, List<MealByCafeteria>> groupedMeals,
  ) {
    final now = DateTime.now();

    /// 가장 늦은 종료시간을 저장할 변수 선언
    DateTime? breakfastMaxEnd, lunchMaxEnd, dinnerMaxEnd;

    final allCafeterias = groupedMeals.values.expand((list) => list);

    // 모든 식당의 운영시간을 순회하며 가장 늦은 종료시간 찾기
    for (final cafeteria in allCafeterias) {
      final bEnd = _latestEndFromHoursString(cafeteria.hours.breakfast, now);
      if (bEnd != null) {
        breakfastMaxEnd =
            (breakfastMaxEnd == null || bEnd.isAfter(breakfastMaxEnd))
            ? bEnd
            : breakfastMaxEnd;
      }
      final lEnd = _latestEndFromHoursString(cafeteria.hours.lunch, now);
      if (lEnd != null) {
        lunchMaxEnd = (lunchMaxEnd == null || lEnd.isAfter(lunchMaxEnd))
            ? lEnd
            : lunchMaxEnd;
      }
      final dEnd = _latestEndFromHoursString(cafeteria.hours.dinner, now);
      if (dEnd != null) {
        dinnerMaxEnd = (dinnerMaxEnd == null || dEnd.isAfter(dinnerMaxEnd))
            ? dEnd
            : dinnerMaxEnd;
      }
    }

    List<String> desiredOrder;
    if (breakfastMaxEnd != null && now.isBefore(breakfastMaxEnd)) {
      desiredOrder = ['아침', '점심', '저녁'];
    } else if (lunchMaxEnd != null && now.isBefore(lunchMaxEnd)) {
      desiredOrder = ['점심', '저녁', '아침'];
    } else if (dinnerMaxEnd != null && now.isBefore(dinnerMaxEnd)) {
      desiredOrder = ['저녁', '아침', '점심'];
    } else {
      // 모든 저녁 식당의 운영이 종료된 이후에는 다음 날 아침을 우선으로 보여줍니다.
      desiredOrder = ['아침', '점심', '저녁'];
    }

    final existingTypes = groupedMeals.keys
        .where((k) => groupedMeals[k]!.isNotEmpty)
        .toList();

    final ordered = <String>[];
    // desiredOrder에 있는 순서대로 먼저 정렬 한다.
    for (final t in desiredOrder) {
      if (existingTypes.contains(t)) ordered.add(t);
    }
    // desiredOrder에 포함되지 않았지만
    // existingTypes(실제 존재하는 시간대 ex. 간식)에는 있었던
    // 나머지 시간대들을 이어서 붙인다.
    for (final t in existingTypes) {
      if (!ordered.contains(t)) ordered.add(t);
    }
    return ordered;
  }

  /// Hours 문자열을 파싱하여 가장 늦은 종료 시각을 구합니다.
  DateTime? _latestEndFromHoursString(String s, DateTime now) {
    if (s.trim().isEmpty) return null;
    final ranges = parseTimeRanges(s, now);
    if (ranges.isEmpty) return null;
    return ranges.map((r) => r.$2).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // 7. buildBody를 FutureBuilder로 재구성
  Widget _buildBody() {
    return FutureBuilder<List<Meal>>(
      future: _mealFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError && snapshot.error is! StaleDataException) {
          return Center(child: Text('식단 정보를 불러오는데 실패했습니다: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("등록된 식단 정보가 없습니다."));
        }

        // 데이터 로딩 성공
        final meals = snapshot.data!;
        final groupedMeals = _groupMeals(meals);
        final mealTypes = _orderedMealTypesByDynamicHours(groupedMeals);

        return Column(
          children: [
            // Stale 데이터 알림 메시지
            // TODO: "API 호출에 실패하여 이전 데이터를 표시합니다."" 라는 메시지를 띄워야할지 생각해야함.
            // 잠깐 슬라이드해서 나타나는 그런 알림으로 잠깐 뜨게하는건 어떨지? (SnackBar 위젯 / Toast 라이브러리 / Flushbar 라이브러리)
            if (_staleDataMessage != null)
              Container(
                width: double.infinity,
                color: Colors.orange.shade100,
                padding: const EdgeInsets.all(8.0),
                child: Text(_staleDataMessage!, textAlign: TextAlign.center),
              ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshMeals, // 당겨서 새로고침 기능 연결
                child: ListView.builder(
                  itemCount: mealTypes.length,
                  itemBuilder: (context, index) {
                    final mealType = mealTypes[index];
                    final mealsByCafeteria = groupedMeals[mealType];

                    if (mealsByCafeteria == null || mealsByCafeteria.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return TimeGroupedCard(
                      title: mealType,
                      mealData: mealsByCafeteria,
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앱의 왼쪽 위
            Text(
              widget.title,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 30),
            ),
            SizedBox(height: 4),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.lightBlue.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                minimumSize: Size.zero, // 최소 사이즈 제거
                tapTargetSize: MaterialTapTargetSize.shrinkWrap, // 탭 영역을 최소화
              ),
              onPressed: () => _selectDate(context), // 탭하면 _selectDate 함수 호출
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 4),
                  Text(
                    DateFormat(
                      'yyyy년 MM월 dd일 (E)',
                      'ko_KR',
                    ).format(_selectedDate), // 날짜 포맷
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // TODO: 설정 나중에 페이지 완성되면 버튼 돌려놓기
          // IconButton(
          //   icon: const Icon(Icons.settings), // 설정 아이콘
          //   tooltip: '설정', // 풍선 도움말
          //   onPressed: () {
          //     Navigator.of(context).push(
          //       PageRouteBuilder(
          //         pageBuilder: (context, animation, secondaryAnimation) =>
          //             const SettingsScreen(),
          //         transitionsBuilder:
          //             (context, animation, secondaryAnimation, child) {
          //               const begin = Offset(1.0, 0.0); // 오른쪽에서 시작
          //               const end = Offset.zero; // 원래 위치로 이동
          //               const curve = Curves.ease; // 부드러운 전환 효과

          //               var tween = Tween(
          //                 begin: begin,
          //                 end: end,
          //               ).chain(CurveTween(curve: curve));
          //               var offsetAnimation = animation.drive(tween);

          //               return SlideTransition(
          //                 position: offsetAnimation,
          //                 child: child,
          //               );
          //             },
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
