import 'package:bobmoo/models/menu_model.dart';
import 'package:bobmoo/services/menu_service.dart';
import 'package:bobmoo/widgets/cafeteria_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 선택한 날짜 저장할 상태 변수수
  DateTime _selectedDate = DateTime.now();

  final MenuService _menuService = MenuService();
  bool _isLoading = true;
  MenuResponse? _menuResponse;
  String? _errorMessage;

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
      final response = await _menuService.getMenu(date);
      setState(() {
        _menuResponse = response;
        _isLoading = false; // 로딩 끝
      });
    } catch (e) {
      setState(() {
        _errorMessage = '식단 정보를 불러오는데 실패했습니다.';
        _isLoading = false; // 로딩 끝 (에러)
      });
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

    // 성공 시 식당 목록을 보여주는 ListView
    return ListView.builder(
      itemCount: _menuResponse!.cafeterias.length,
      itemBuilder: (context, index) {
        final cafeteria = _menuResponse!.cafeterias[index];
        return CafeteriaCard(cafeteria: cafeteria);
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
