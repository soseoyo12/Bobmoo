import 'dart:io';

import 'package:bobmoo/collections/meal_collection.dart';
import 'package:bobmoo/collections/restaurant_collection.dart';
import 'package:bobmoo/locator.dart';
import 'package:bobmoo/models/meal_by_cafeteria.dart';
import 'package:bobmoo/models/menu_model.dart';
import 'package:bobmoo/repositories/meal_repository.dart';
import 'package:bobmoo/models/meal_widget_data.dart';
import 'package:bobmoo/services/widget_service.dart';
import 'package:bobmoo/widgets/time_grouped_card.dart';
import 'package:bobmoo/utils/hours_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  // 1. 상태변구 변경: Future 객체로 데이터와 로딩 상태를 한번에 관리
  final MealRepository _repository = locator<MealRepository>();
  late Future<List<Meal>> _mealFuture;

  /// 선택한 날짜 저장할 상태 변수
  DateTime _selectedDate = DateTime.now();

  /// 화면이 처음 나타날 때 데이터 불러오기
  @override
  void initState() {
    super.initState();
    // 앱 상태를 확인하기 위한 옵저버 할당
    WidgetsBinding.instance.addObserver(this);
    // 앱 시작 시 업데이트 확인
    checkForUpdate();
    // initState에서는 setState를 호출하지 않고, Future를 직접 할당합니다.
    _mealFuture = _fetchData();

    // 앱 시작 시에도 위젯 업데이트
    _updateWidgetOnly();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 포그라운드로 돌아올 때마다 위젯 업데이트
    if (state == AppLifecycleState.resumed) {
      _updateWidgetOnly();
    }
  }

  /// 인앱 업데이트를 확인하고, 가능하면 유연한 업데이트를 시작하는 함수
  Future<void> checkForUpdate() async {
    try {
      // 1. 업데이트가 사용 가능한지 확인합니다.
      final AppUpdateInfo updateInfo = await InAppUpdate.checkForUpdate();

      // 2. 업데이트가 있고, 유연한 업데이트(FLEXIBLE)가 허용되는 경우
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable &&
          updateInfo.flexibleUpdateAllowed) {
        // 3. 유연한 업데이트를 시작합니다.
        await InAppUpdate.startFlexibleUpdate();

        // 4. 다운로드가 완료되면 사용자에게 설치를 요청합니다.
        //    SnackBar나 다른 UI 요소를 사용하여 알릴 수 있습니다.
        await InAppUpdate.completeFlexibleUpdate()
            .then((_) {
              // 이곳에 업데이트 완료 후 처리할 로직을 추가할 수 있습니다.
              if (kDebugMode) {
                print("업데이트가 완료되었습니다.");
              }
            })
            .catchError((e) {
              if (kDebugMode) {
                print(e.toString());
              }
            });
      }
    } catch (e) {
      // 오류 처리
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  /// 데이터 로딩의 비동기 로직 함수
  /// Repository에게 식단 데이터를 요청한다.
  Future<List<Meal>> _fetchData() async {
    try {
      final meals = await _repository.getMealsForDate(_selectedDate);

      // 데이터 로딩 시에도 조건부 위젯 업데이트
      _updateWidgetOnly();

      return meals;
    } catch (e) {
      if (e is StaleDataException) {
        // 신선도가 떨어진 데이터를 취급하는 경우
        _showStaleDataSnackbar(e);
        // 데이터를 반환하여 화면은 정상적으로 그리도록 함
        return e.staleData;
      } else if (e is SocketException) {
        // 네트워크 연결이 없는경우
        throw NetworkException();
      }
      // 다른 모든 에러는 FutureBuilder로 전달
      rethrow;
    }
  }

  /// 위젯 데이터 업데이트 함수 (오늘날짜)
  Future<void> _updateWidgetOnly() async {
    // 오늘 날짜인 경우에만 위젯 업데이트
    try {
      final today = DateTime.now();
      // 1. 오늘 날짜의 메뉴 데이터 가져오기
      final todayMeals = await _repository.getMealsForDate(today);

      // 2. 데이터가 없으면 위젯 업데이트하지 않음
      if (todayMeals.isEmpty) {
        return;
      }

      // 3. 데이터 구조 변환
      final groupedMeals = _groupMeals(todayMeals);
      final mealTypes = _orderedMealTypesByDynamicHours(groupedMeals);

      // 4. 첫 번째 식당 선택
      // TODO: 식당 선택하는 설정 페이지 만들고 연결해야함.
      final firstType = mealTypes.firstWhere(
        (t) => groupedMeals[t]!.isNotEmpty,
        orElse: () => mealTypes.first,
      );
      final firstCafeteria = groupedMeals[firstType]!.first;

      // 5. 위젯 데이터 생성 및 저장
      final widgetData = MealWidgetData.fromGrouped(
        date: DateFormat('yyyy-MM-dd').format(today), // 항상 오늘 날짜
        cafeteriaName: firstCafeteria.cafeteriaName,
        grouped: groupedMeals.map((k, v) => MapEntry(k, v)),
        hours: firstCafeteria.hours,
      );

      if (kDebugMode) {
        debugPrint('✅ 위젯 데이터 업데이트 성공!');
      }

      await WidgetService.saveMealWidgetData(widgetData);
    } catch (e) {
      // 위젯 업데이트 실패는 조용히 무시 (사용자 경험에 영향 없음)
      if (kDebugMode) {
        debugPrint('위젯 업데이트 실패: $e');
      }
    }
  }

  /// StaleDataException 발생 시 SnackBar를 띄우는 헬퍼 함수
  void _showStaleDataSnackbar(StaleDataException e) {
    // SnackBar는 build가 완료된 후에 띄워야 하므로 addPostFrameCallback 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // 위젯이 화면에 아직 있는지 확인
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.message,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  // 날짜 변경 시에는 setState로 Future를 교체해줍니다.
  void _loadMeals() {
    setState(() {
      _mealFuture = _fetchData();
    });
  }

  // 3. 새로고침 함수 추가
  /// Pull-to-Refresh(당겨서 새로고침)을 위한 새로고침 함수
  Future<void> _refreshMeals() async {
    setState(() {
      // catchError 내부를 async로 만들어 await를 사용할 수 있게 합니다.
      _mealFuture = _repository.forceRefreshMeals(_selectedDate).catchError((
        e,
      ) async {
        // 1. API 호출이 실패하면 (SocketException 등)
        if (e is SocketException) {
          // 2. 로컬 DB에 저장된 데이터라도 있는지 확인합니다.
          final localData = await _repository.fetchFromDb(_selectedDate);
          if (localData.isNotEmpty) {
            // 3a. 로컬 데이터가 있으면, SnackBar를 띄우고 그 데이터를 반환합니다.
            _showStaleDataSnackbar(
              StaleDataException(
                localData,
                message: "새로고침에 실패했습니다. 오프라인 정보를 표시합니다.",
              ),
            );
            return localData;
          }
        }
        // 3b. 로컬 데이터조차 없거나 다른 종류의 에러이면, 에러 화면을 보여줍니다.
        throw NetworkException();
      });
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
    final ranges = parseTimeRanges(s: s, now: now);
    if (ranges.isEmpty) return null;
    return ranges.map((r) => r.$2).reduce((a, b) => a.isAfter(b) ? a : b);
  }

  /// 에러 상황에 맞는 위젯을 생성하는 함수
  Widget _buildErrorWidget(Object error) {
    String message;
    IconData icon;

    // 에러 확인
    if (error is NetworkException) {
      message = "인터넷 연결을 확인해주세요.";
      icon = Icons.wifi_off_rounded;
    } else {
      message = "알 수 없는 오류가 발생했습니다.";
      icon = Icons.error_outline_rounded;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 60, color: Colors.grey),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {
              _loadMeals();
            }), // 재시도 버튼
            child: const Text("다시 시도"),
          ),
        ],
      ),
    );
  }

  // 7. buildBody를 FutureBuilder로 재구성
  Widget _buildBody() {
    return FutureBuilder<List<Meal>>(
      future: _mealFuture,
      builder: (context, snapshot) {
        // 로딩 중
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        // 에러 발생
        if (snapshot.hasError) {
          return _buildErrorWidget(snapshot.error!);
        }
        // 데이터 없음
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("등록된 식단 정보가 없습니다."),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() {
                    _refreshMeals();
                  }),
                  child: const Text("새로고침"),
                ),
              ],
            ),
          );
        }

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

        return RefreshIndicator(
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
                selectedDate: _selectedDate,
              );
            },
          ),
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
