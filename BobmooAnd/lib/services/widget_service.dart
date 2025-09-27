import 'dart:convert';
import 'package:home_widget/home_widget.dart';
import 'package:bobmoo/models/meal_widget_data.dart';

class WidgetService {
  static const String _widgetDataKey = 'widgetData';

  /// MealWidgetData를 JSON으로 저장하고 위젯 업데이트 트리거
  static Future<void> saveMealWidgetData(MealWidgetData data) async {
    final jsonString = jsonEncode(data.toJson());
    await HomeWidget.saveWidgetData<String>(_widgetDataKey, jsonString);
    await HomeWidget.updateWidget(
      // Glance 업데이트 트리거
      qualifiedAndroidName: 'com.hwoo.bobmoo.MealGlanceWidgetReceiver',
    );
  }

  /// 현재 선택한 시간대에 맞춰 요약 텍스트를 만들어 저장
  /// 위젯은 Kotlin에서 JSON을 파싱해 시간대별로 표시를 담당
  static Future<void> saveFromRawJson(String jsonString) async {
    await HomeWidget.saveWidgetData<String>(_widgetDataKey, jsonString);
    await HomeWidget.updateWidget(
      qualifiedAndroidName: 'com.hwoo.bobmoo.MealGlanceWidgetReceiver',
    );
  }
}
