import 'package:bobmoo/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // initState에서 권한 상태를 가져오기 위해 Future 사용
  late Future<bool> _permissionFuture;

  /// 사용 가능한 전체 식당 리스트
  /// TODO: 나중에 enum 같은걸 만들어서 대학별로 관리하기
  final List<String> _cafeteriaList = ['학생식당', '생활관식당', '교직원식당'];

  /// 현재 선택된 대표 식당
  String? _selectedCafeteria;

  @override
  void initState() {
    super.initState();
    _permissionFuture = PermissionService.canScheduleExactAlarms();

    // 설정 화면에 진입하면 배너 닫힘 상태를 초기화합니다.
    _resetBannerDismissalStatus();

    _loadSelectedCafeteria();
  }

  Future<void> _resetBannerDismissalStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // '닫음' 상태를 false로 되돌려서, 홈 화면에서 배너가 다시 보일 수 있도록 함
    await prefs.setBool('permissionBannerDismissed', false);
  }

  /// 화면이 로드될 때 저장된 대표 식당 설정을 불러옵니다.
  Future<void> _loadSelectedCafeteria() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 'selectedCafeteriaName' 키로 저장된 값을 불러옵니다. 없으면 첫 번째 식당을 기본값으로.
      _selectedCafeteria =
          prefs.getString('selectedCafeteriaName') ?? _cafeteriaList.first;
    });
  }

  Future<void> _saveSelectedCafeteria(String cafeteriaName) async {
    final prefs = await SharedPreferences.getInstance();
    // 'selectedCafeteriaName' 라는 새로운 키로 선택된 식당 이름을 저장합니다.
    await prefs.setString('selectedCafeteriaName', cafeteriaName);
    setState(() {
      _selectedCafeteria = cafeteriaName;
    });
    // 나중에 대표 식당 변경 후 즉시 위젯을 업데이트하고 싶다면 여기서 위젯 업데이트 함수 호출
    // 예: WidgetService.saveAllCafeteriasWidgetData(...);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정', style: TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          // --- 대표 식당 선택 UI ---
          ListTile(
            title: const Text('2x2 위젯 대표 식당 설정'),
            subtitle: Text('기본 위젯에 표시될 식당을 선택하세요.'),
            trailing: DropdownButton<String>(
              value: _selectedCafeteria,
              items: _cafeteriaList.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _saveSelectedCafeteria(newValue);
                }
              },
            ),
          ),

          // --- 위젯 실시간 업데이트 UI ---
          FutureBuilder<bool>(
            future: _permissionFuture,
            builder: (context, snapshot) {
              // 아직 데이터를 가져오는 중이면 로딩 인디케이터 표시
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const ListTile(
                  title: Text('위젯 업데이트 권한'),
                  subtitle: Text('권한 상태를 확인 중입니다...'),
                );
              }

              final bool hasPermission = snapshot.data ?? false;

              return ListTile(
                title: const Text('위젯 실시간 업데이트'),
                subtitle: Text(
                  hasPermission
                      ? '활성화됨: 위젯이 매분 자동으로 업데이트됩니다.'
                      : '비활성화됨: 권한을 설정하여 실시간 업데이트를 켜세요.',
                ),
                trailing: Icon(
                  hasPermission ? Icons.check_circle : Icons.warning,
                  color: hasPermission ? Colors.green : Colors.orange,
                ),
                onTap: () async {
                  // 탭하면 설정 화면으로 이동
                  await PermissionService.openAlarmPermissionSettings();
                  // 설정 후 돌아왔을 때 상태를 갱신하기 위해 setState로 Future를 다시 할당
                  setState(() {
                    _permissionFuture =
                        PermissionService.canScheduleExactAlarms();
                  });
                },
              );
            },
          ),
          // --- 다른 설정 메뉴들을 여기에 추가 ---
        ],
      ),
    );
  }
}
