import 'package:bobmoo/models/meal_by_cafeteria.dart';
import 'package:bobmoo/models/menu_model.dart';
import 'package:bobmoo/services/menu_service.dart';
import 'package:bobmoo/widgets/time_grouped_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 선택한 날짜 저장할 상태 변수
  DateTime _selectedDate = DateTime.now();

  // API 기본 세팅 변수
  final MenuService _menuService = MenuService();

  // 로딩중인지 여부
  bool _isLoading = true;

  // API 응답 저장 변수
  MenuResponse? _menuResponse;

  // 에러메시지 변수
  String? _errorMessage;

  // 시간대별로 그룹화된 데이터를 담을 새로운 Map 변수
  Map<String, List<MealByCafeteria>> _groupedMeals = {};

  // 화면이 처음 나타날 때 데이터 불러오기
  @override
  void initState() {
    super.initState();
    _fetchMenu(_selectedDate); // 초기 날짜(시작 날짜)로 데이터 로드
  }

  Future<void> _fetchMenu(DateTime date) async {
    setState(() {
      _isLoading = true; // 로딩 시작
      _errorMessage = null;
    });

    try {
      // _menuService를 통해 'date' 날짜에 해당하는 식단을 불러옴.
      final response = await _menuService.getMenu(date);

      // 응답 저장
      _menuResponse = response;

      // 시간대별로 구조 변경
      _groupMealsByTime(response);

      _isLoading = false; // 로딩 끝
    } catch (e) {
      _errorMessage = '식단 정보를 불러오는데 실패했습니다.';
      _isLoading = false; // 로딩 끝 (에러)
    } finally {
      setState(() {});
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate, // 초기 선택된 날짜
      firstDate: DateTime(2020), // 선택 가능한 시작 날짜
      lastDate: DateTime(2030), // 선택 가능한 마지막 날짜
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked; // 날짜가 선택되면 상태 업데이트
      });
      _fetchMenu(_selectedDate);
    }
  }

  void _groupMealsByTime(MenuResponse response) {
    // 임시로 사용할 리스트들을 만듭니다.
    final List<MealByCafeteria> breakfastMenus = [];
    final List<MealByCafeteria> lunchMenus = [];
    final List<MealByCafeteria> dinnerMenus = [];

    // API 응답에 있는 모든 식당을 순회합니다.
    for (var cafeteria in response.cafeterias) {
      // 아침 메뉴가 있다면 breakfastMenus 리스트에 추가
      if (cafeteria.meals.breakfast.isNotEmpty) {
        breakfastMenus.add(
          MealByCafeteria(
            cafeteriaName: cafeteria.name,
            meals: cafeteria.meals.breakfast,
          ),
        );
      }
      // 점심 메뉴가 있다면 lunchMenus 리스트에 추가
      if (cafeteria.meals.lunch.isNotEmpty) {
        lunchMenus.add(
          MealByCafeteria(
            cafeteriaName: cafeteria.name,
            meals: cafeteria.meals.lunch,
          ),
        );
      }
      // 저녁 메뉴가 있다면 dinnerMenus 리스트에 추가
      if (cafeteria.meals.dinner.isNotEmpty) {
        dinnerMenus.add(
          MealByCafeteria(
            cafeteriaName: cafeteria.name,
            meals: cafeteria.meals.dinner,
          ),
        );
      }
    }

    // 최종적으로 상태 변수에 데이터를 채워넣습니다.
    setState(() {
      _groupedMeals = {
        '아침': breakfastMenus,
        '점심': lunchMenus,
        '저녁': dinnerMenus,
      };
    });
  }

  Widget _buildBody() {
    if (_isLoading) {
      // 로딩 상태
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      // 에러 메시지 발생
      return Center(child: Text(_errorMessage!));
    }
    if (_menuResponse == null || _menuResponse!.cafeterias.isEmpty) {
      // menuResponse가 없거나 모든 식당이 비었을때.
      return const Center(child: Text("등록된 식단 정보가 없습니다."));
    }

    // 그룹화된 맵의 키('아침', '점심', '저녁')들로 리스트를 만듭니다.
    final mealTypes = _groupedMeals.keys.toList();

    // 성공 시 식당 목록을 보여주는 ListView
    return ListView.builder(
      itemCount: mealTypes.length,
      itemBuilder: (context, index) {
        final mealType = mealTypes[index];
        final mealsByCafeteria = _groupedMeals[mealType]; // '아침', '점심', '저녁'

        // 만약 해당 시간대에 메뉴가 하나도 없으면 그 섹션은 그리지 않습니다.
        if (mealsByCafeteria == null || mealsByCafeteria.isEmpty) {
          return const SizedBox.shrink();
        }

        return TimeGroupedCard(
          title: mealType,
          mealData: mealsByCafeteria,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앱의 왼쪽 위
            Text(
              "인하대학교",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
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
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings), // 설정 아이콘
            tooltip: '설정', // 풍선 도움말
            onPressed: () {
              // 버튼을 눌렀을 때 실행될 코드
              // TODO: 설정버튼
              // 예: Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
