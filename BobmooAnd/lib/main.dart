import 'package:bobmoo/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 로케일데이터 추가
  await initializeDateFormatting('ko_KR', null);

  runApp(const BobMooApp());
}

class BobMooApp extends StatelessWidget {
  const BobMooApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
