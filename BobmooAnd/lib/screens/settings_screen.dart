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

  @override
  void initState() {
    super.initState();
    _permissionFuture = PermissionService.canScheduleExactAlarms();

    // 설정 화면에 진입하면 배너 닫힘 상태를 초기화합니다.
    _resetBannerDismissalStatus();
  }

  // 새로 추가된 함수
  Future<void> _resetBannerDismissalStatus() async {
    final prefs = await SharedPreferences.getInstance();
    // '닫음' 상태를 false로 되돌려서, 홈 화면에서 배너가 다시 보일 수 있도록 함
    await prefs.setBool('permissionBannerDismissed', false);
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
          // FutureBuilder를 사용하여 비동기적으로 권한 상태를 가져와 UI를 그림
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
