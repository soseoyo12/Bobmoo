import 'package:bobmoo/models/menu_model.dart';

class MealWidgetData {
  final String cafeteriaName;
  final Hours hours;
  final List<MealItem> meals;

  MealWidgetData({
    required this.cafeteriaName,
    required this.hours,
    required this.meals,
  });
}
