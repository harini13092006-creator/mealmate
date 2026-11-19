import 'package:uuid/uuid.dart';
import '../../core/storage/local_storage_service.dart';
import '../../domain/models/meal_plan.dart';
import '../../domain/models/recipe.dart';
import '../../domain/repositories/meal_plan_repository.dart';
import '../../domain/repositories/recipe_repository.dart';
import 'mock_recipe_repository.dart';

class MockMealPlanRepository implements MealPlanRepository {
  final List<PlannedMeal> _meals = [];
  final _uuid = const Uuid();
  final RecipeRepository _recipeRepo;
  final LocalStorageService _localStorageService;
  Future<void>? _loadFuture;

  MockMealPlanRepository({
    RecipeRepository? recipeRepo,
    LocalStorageService? localStorageService,
  })  : _recipeRepo = recipeRepo ?? MockRecipeRepository(),
        _localStorageService = localStorageService ?? LocalStorageService();

  Future<void> _ensureLoaded() {
    _loadFuture ??= _loadData();
    return _loadFuture!;
  }

  Future<void> _loadData() async {
    try {
      final storedJson = await _localStorageService.getMealPlansJson();
      if (storedJson.isNotEmpty) {
        final allRecipes = await _recipeRepo.getRecipes();
        final recipeMap = {for (final r in allRecipes) r.id: r};

        final restored = <PlannedMeal>[];
        for (final item in storedJson) {
          final recipeId = item['recipeId'] as String?;
          final recipe = recipeMap[recipeId] ??
              (allRecipes.isNotEmpty ? allRecipes.first : null);
          if (recipe != null) {
            restored.add(PlannedMeal.fromJson(item, recipe));
          }
        }
        _meals.clear();
        _meals.addAll(restored);
        return;
      }

      // First run: Seed initial planned meals across the current week
      final now = DateTime.now();
      final list = await _recipeRepo.getRecipes();
      if (list.length >= 6 && _meals.isEmpty) {
        final monday = now.subtract(Duration(days: now.weekday - 1));

        _meals.addAll([
          // Monday
          PlannedMeal(
            id: _uuid.v4(),
            date: DateTime(monday.year, monday.month, monday.day),
            mealType: MealType.breakfast,
            recipe: list[6], // Avocado toast
            isCompleted: true,
          ),
          PlannedMeal(
            id: _uuid.v4(),
            date: DateTime(monday.year, monday.month, monday.day),
            mealType: MealType.lunch,
            recipe: list[8], // Mediterranean Quinoa Bowl
            isCompleted: true,
          ),
          PlannedMeal(
            id: _uuid.v4(),
            date: DateTime(monday.year, monday.month, monday.day),
            mealType: MealType.dinner,
            recipe: list[0], // Garlic Butter Shrimp Pasta
            isCompleted: false,
          ),

          // Tuesday
          PlannedMeal(
            id: _uuid.v4(),
            date: DateTime(monday.year, monday.month, monday.day + 1),
            mealType: MealType.breakfast,
            recipe: list[14], // Berry Smoothie Bowl
            isCompleted: false,
          ),
          PlannedMeal(
            id: _uuid.v4(),
            date: DateTime(monday.year, monday.month, monday.day + 1),
            mealType: MealType.dinner,
            recipe: list[4], // Lemon Herb Salmon
            isCompleted: false,
          ),

          // Wednesday
          PlannedMeal(
            id: _uuid.v4(),
            date: DateTime(monday.year, monday.month, monday.day + 2),
            mealType: MealType.lunch,
            recipe: list[11], // Chipotle Burrito Bowl
            isCompleted: false,
          ),
          PlannedMeal(
            id: _uuid.v4(),
            date: DateTime(monday.year, monday.month, monday.day + 2),
            mealType: MealType.dinner,
            recipe: list[16], // Molten Chocolate Lava Cake
            isCompleted: false,
          ),

          // Thursday
          PlannedMeal(
            id: _uuid.v4(),
            date: DateTime(monday.year, monday.month, monday.day + 3),
            mealType: MealType.breakfast,
            recipe: list[2], // Egg fried rice
            isCompleted: false,
          ),
          PlannedMeal(
            id: _uuid.v4(),
            date: DateTime(monday.year, monday.month, monday.day + 3),
            mealType: MealType.dinner,
            recipe: list[10], // Teriyaki Salmon Poke
            isCompleted: false,
          ),

          // Friday
          PlannedMeal(
            id: _uuid.v4(),
            date: DateTime(monday.year, monday.month, monday.day + 4),
            mealType: MealType.lunch,
            recipe: list[1], // Chicken quesadilla
            isCompleted: false,
          ),
          PlannedMeal(
            id: _uuid.v4(),
            date: DateTime(monday.year, monday.month, monday.day + 4),
            mealType: MealType.dinner,
            recipe: list[7], // Margherita flatbread
            isCompleted: false,
          ),
        ]);

        await _saveToStorage();
      }
    } catch (_) {
      // Fallback
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final jsonList = _meals.map((m) => m.toJson()).toList();
      await _localStorageService.saveMealPlansJson(jsonList);
    } catch (_) {
      // Ignore storage write error
    }
  }

  @override
  Future<List<PlannedMeal>> getMealsForDate(DateTime date) async {
    await _ensureLoaded();
    return _meals.where((m) =>
        m.date.year == date.year &&
        m.date.month == date.month &&
        m.date.day == date.day).toList();
  }

  @override
  Future<List<PlannedMeal>> getMealsForWeek(DateTime startOfWeek) async {
    await _ensureLoaded();
    final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final end = start.add(const Duration(days: 7));

    return _meals.where((m) {
      final mealDate = DateTime(m.date.year, m.date.month, m.date.day);
      return !mealDate.isBefore(start) && mealDate.isBefore(end);
    }).toList();
  }

  @override
  Future<void> addMealPlan({
    required DateTime date,
    required MealType mealType,
    required Recipe recipe,
  }) async {
    await _ensureLoaded();
    // If a meal for this date and type already exists, replace it to avoid collision
    final existingIndex = _meals.indexWhere((m) =>
        m.date.year == date.year &&
        m.date.month == date.month &&
        m.date.day == date.day &&
        m.mealType == mealType);

    if (existingIndex != -1) {
      _meals[existingIndex] = PlannedMeal(
        id: _meals[existingIndex].id,
        date: DateTime(date.year, date.month, date.day),
        mealType: mealType,
        recipe: recipe,
      );
    } else {
      _meals.add(
        PlannedMeal(
          id: _uuid.v4(),
          date: DateTime(date.year, date.month, date.day),
          mealType: mealType,
          recipe: recipe,
        ),
      );
    }
    await _saveToStorage();
  }

  @override
  Future<void> replaceMealPlan({
    required String mealId,
    required Recipe newRecipe,
  }) async {
    await _ensureLoaded();
    final index = _meals.indexWhere((m) => m.id == mealId);
    if (index != -1) {
      final current = _meals[index];
      _meals[index] = current.copyWith(
        recipe: newRecipe,
        recipeId: newRecipe.id,
      );
      await _saveToStorage();
    }
  }

  @override
  Future<void> removeMealPlan(String mealId) async {
    await _ensureLoaded();
    _meals.removeWhere((m) => m.id == mealId);
    await _saveToStorage();
  }

  @override
  Future<void> toggleMealCompleted(String mealId) async {
    await _ensureLoaded();
    final index = _meals.indexWhere((m) => m.id == mealId);
    if (index != -1) {
      final current = _meals[index];
      _meals[index] = current.copyWith(isCompleted: !current.isCompleted);
      await _saveToStorage();
    }
  }

  @override
  Future<void> clearAllMealPlans() async {
    await _ensureLoaded();
    _meals.clear();
    await _saveToStorage();
  }
}
