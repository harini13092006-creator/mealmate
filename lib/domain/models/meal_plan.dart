import 'package:intl/intl.dart';
import 'recipe.dart';

enum MealType { breakfast, lunch, dinner }

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
    }
  }
}

class PlannedMeal {
  final String id;
  final DateTime date;
  final String day;
  final MealType mealType;
  final String recipeId;
  final Recipe recipe;
  final bool isCompleted;

  PlannedMeal({
    required this.id,
    required this.date,
    String? day,
    required this.mealType,
    String? recipeId,
    required this.recipe,
    this.isCompleted = false,
  })  : day = day ?? DateFormat('EEEE').format(date),
        recipeId = recipeId ?? recipe.id;

  PlannedMeal copyWith({
    String? id,
    DateTime? date,
    String? day,
    MealType? mealType,
    String? recipeId,
    Recipe? recipe,
    bool? isCompleted,
  }) {
    return PlannedMeal(
      id: id ?? this.id,
      date: date ?? this.date,
      day: day ?? this.day,
      mealType: mealType ?? this.mealType,
      recipeId: recipeId ?? this.recipeId,
      recipe: recipe ?? this.recipe,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'day': day,
      'mealType': mealType.name,
      'recipeId': recipeId,
      'isCompleted': isCompleted,
    };
  }

  factory PlannedMeal.fromJson(Map<String, dynamic> json, Recipe recipe) {
    final mealTypeStr = (json['mealType'] ?? 'dinner').toString().toLowerCase();
    final mealType = MealType.values.firstWhere(
      (e) => e.name.toLowerCase() == mealTypeStr,
      orElse: () => MealType.dinner,
    );

    return PlannedMeal(
      id: json['id'] as String? ?? '',
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      day: json['day'] as String?,
      mealType: mealType,
      recipeId: json['recipeId'] as String? ?? recipe.id,
      recipe: recipe,
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }
}

typedef MealPlan = PlannedMeal;
