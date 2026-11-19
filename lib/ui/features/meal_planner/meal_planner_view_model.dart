import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../domain/models/meal_plan.dart';
import '../../../domain/models/recipe.dart';
import '../../../domain/repositories/meal_plan_repository.dart';
import '../../../domain/repositories/recipe_repository.dart';

class MealPlannerViewModel extends ChangeNotifier {
  final MealPlanRepository mealPlanRepository;
  final RecipeRepository recipeRepository;

  late DateTime _currentWeekStart;
  late DateTime _selectedDate;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<PlannedMeal> _weekMeals = [];
  List<PlannedMeal> get weekMeals => _weekMeals;

  List<PlannedMeal> _plannedMeals = [];
  List<PlannedMeal> get plannedMeals => _plannedMeals;

  List<Recipe> _availableRecipes = [];
  List<Recipe> get availableRecipes => _availableRecipes;

  DateTime get currentWeekStart => _currentWeekStart;
  DateTime get selectedDate => _selectedDate;

  List<DateTime> get weekDays {
    return List.generate(
      7,
      (i) => DateTime(
        _currentWeekStart.year,
        _currentWeekStart.month,
        _currentWeekStart.day + i,
      ),
    );
  }

  String get weekRangeFormatted {
    final start = _currentWeekStart;
    final end = DateTime(start.year, start.month, start.day + 6);
    if (start.month == end.month) {
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('d, yyyy').format(end)}';
    }
    return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
  }

  MealPlannerViewModel({
    required this.mealPlanRepository,
    required this.recipeRepository,
  }) {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentWeekStart = _selectedDate.subtract(Duration(days: _selectedDate.weekday - 1));
    loadPlannerData();
  }

  DateTime _getMonday(DateTime d) {
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: d.weekday - 1));
  }

  void selectDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
    final monday = _getMonday(_selectedDate);
    if (monday != _currentWeekStart) {
      _currentWeekStart = monday;
    }
    loadPlannerData();
  }

  void previousWeek() {
    _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7));
    _selectedDate = _selectedDate.subtract(const Duration(days: 7));
    loadPlannerData();
  }

  void nextWeek() {
    _currentWeekStart = _currentWeekStart.add(const Duration(days: 7));
    _selectedDate = _selectedDate.add(const Duration(days: 7));
    loadPlannerData();
  }

  void jumpToToday() {
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentWeekStart = _getMonday(_selectedDate);
    loadPlannerData();
  }

  bool _disposed = false;

  Future<void> loadPlannerData() async {
    if (_disposed) return;
    _isLoading = true;
    notifyListeners();

    try {
      final weekMeals = await mealPlanRepository.getMealsForWeek(_currentWeekStart);
      final plannedMeals = await mealPlanRepository.getMealsForDate(_selectedDate);
      final availableRecipes = await recipeRepository.getRecipes();
      if (_disposed) return;
      _weekMeals = weekMeals;
      _plannedMeals = plannedMeals;
      _availableRecipes = availableRecipes;
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  PlannedMeal? getMealForSlot(MealType type, {DateTime? date}) {
    final targetDate = date ?? _selectedDate;
    try {
      return _weekMeals.firstWhere(
        (m) =>
            m.date.year == targetDate.year &&
            m.date.month == targetDate.month &&
            m.date.day == targetDate.day &&
            m.mealType == type,
      );
    } catch (_) {
      return null;
    }
  }

  int getPlannedCountForDay(DateTime day) {
    return _weekMeals.where((m) =>
        m.date.year == day.year &&
        m.date.month == day.month &&
        m.date.day == day.day).length;
  }

  Future<void> addMeal(MealType mealType, Recipe recipe, {DateTime? date}) async {
    final targetDate = date ?? _selectedDate;
    await mealPlanRepository.addMealPlan(
      date: targetDate,
      mealType: mealType,
      recipe: recipe,
    );
    await loadPlannerData();
  }

  Future<void> replaceMeal(String mealId, Recipe newRecipe) async {
    await mealPlanRepository.replaceMealPlan(
      mealId: mealId,
      newRecipe: newRecipe,
    );
    await loadPlannerData();
  }

  Future<void> removeMeal(String mealId) async {
    await mealPlanRepository.removeMealPlan(mealId);
    await loadPlannerData();
  }

  Future<void> toggleCompleted(String mealId) async {
    await mealPlanRepository.toggleMealCompleted(mealId);
    await loadPlannerData();
  }

  Future<void> clearAllMeals() async {
    await mealPlanRepository.clearAllMealPlans();
    await loadPlannerData();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
