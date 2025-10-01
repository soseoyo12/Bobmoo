import 'package:bobmoo/constants/app_constants.dart';
import 'package:bobmoo/locator.dart';
import 'package:bobmoo/screens/home_screen.dart';
import 'package:bobmoo/services/background_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:workmanager/workmanager.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 로케일데이터 추가
  await initializeDateFormatting('ko_KR', null);

  // 앱 실행 전에 GetIt 설정 실행
  await setupLocator();

  // Workmanager 설정
  Workmanager().initialize(callbackDispatcher);

  Workmanager().registerPeriodicTask(
    uniqueTaskName, // 작업의 고유한 이름
    fetchMealDataTask, // callbackDispatcher에서 식별할 작업 이름
    frequency: const Duration(hours: 6), // 실행 주기
    // 동일한 이름의 작업이 이미 있으면 유지하도록 설정
    existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    constraints: Constraints(
      networkType: NetworkType.connected, // 네트워크가 연결되었을 때만 실행
    ),
  );

  runApp(const BobMooApp());
}

class BobMooApp extends StatelessWidget {
  const BobMooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '밥묵자',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color.fromRGBO(204, 221, 228, 1),
        ),
        useMaterial3: true,
      ),
      locale: const Locale('ko', 'KR'), // 앱의 기본 언어를 한국어로 설정
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        // Locale('en', 'US'), // 지원할 언어 목록에 한국어와 영어를 나중에
      ],
      home: const MyHomePage(title: '인하대학교'),
    );
  }
}
