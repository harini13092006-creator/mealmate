import '../models/meal_plan.dart';
import '../models/recipe.dart';

abstract class MealPlanRepository {
  Future<List<PlannedMeal>> getMealsForDate(DateTime date);
  Future<List<PlannedMeal>> getMealsForWeek(DateTime startOfWeek);
  Future<void> addMealPlan({
    required DateTime date,
    required MealType mealType,
    required Recipe recipe,
  });
  Future<void> replaceMealPlan({
    required String mealId,
    required Recipe newRecipe,
  });
  Future<void> removeMealPlan(String mealId);
  Future<void> toggleMealCompleted(String mealId);
  Future<void> clearAllMealPlans();
}
