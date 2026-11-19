import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mateapp/core/storage/local_storage_service.dart';
import 'package:meal_mateapp/data/repositories/json_recipe_repository.dart';
import 'package:meal_mateapp/data/repositories/mock_meal_plan_repository.dart';
import 'package:meal_mateapp/domain/models/meal_plan.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Offline Local Persistence & App Restart Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('Favorite recipes persist across repository and service restarts', () async {
      // Session 1: User launches app and favorites 'qm_01' (Garlic Butter Shrimp Pasta)
      final storage1 = LocalStorageService();
      final repo1 = JsonRecipeRepository(localStorageService: storage1);
      final recipes1 = await repo1.getRecipes();

      final firstRecipe = recipes1.first;
      expect(firstRecipe.isFavorite, isFalse);

      await repo1.toggleFavorite(firstRecipe.id);
      final updated1 = await repo1.getRecipeById(firstRecipe.id);
      expect(updated1!.isFavorite, isTrue);

      // Session 2: User closes and restarts the application (fresh instances)
      final storage2 = LocalStorageService();
      final repo2 = JsonRecipeRepository(localStorageService: storage2);
      final recipes2 = await repo2.getRecipes();

      final restoredRecipe = recipes2.firstWhere((r) => r.id == firstRecipe.id);
      expect(restoredRecipe.isFavorite, isTrue,
          reason: 'Favorite status must be restored automatically on restart');

      // Session 2: User unfavorites the recipe
      await repo2.toggleFavorite(firstRecipe.id);
      final unfavorited2 = await repo2.getRecipeById(firstRecipe.id);
      expect(unfavorited2!.isFavorite, isFalse);

      // Session 3: Restart app again - verify removed favorite remains removed
      final storage3 = LocalStorageService();
      final repo3 = JsonRecipeRepository(localStorageService: storage3);
      final recipes3 = await repo3.getRecipes();
      final restoredRecipe3 = recipes3.firstWhere((r) => r.id == firstRecipe.id);
      expect(restoredRecipe3.isFavorite, isFalse,
          reason: 'Removed favorite must remain removed after restart');
    });

    test('Weekly meal planner persists assignments across application restarts', () async {
      // Session 1: Launch and customize meals
      final storage1 = LocalStorageService();
      final recipeRepo1 = JsonRecipeRepository(localStorageService: storage1);
      await recipeRepo1.getRecipes();

      final plannerRepo1 = MockMealPlanRepository(
        recipeRepo: recipeRepo1,
        localStorageService: storage1,
      );

      final date = DateTime(2026, 11, 23); // Monday
      final recipes = await recipeRepo1.getRecipes();
      final customRecipe = recipes[3]; // Lemon Herb Chicken or similar

      // Assign custom recipe to Dinner on Monday
      await plannerRepo1.addMealPlan(
        date: date,
        mealType: MealType.dinner,
        recipe: customRecipe,
      );

      final mondayMeals1 = await plannerRepo1.getMealsForDate(date);
      final dinnerMeal1 = mondayMeals1.firstWhere((m) => m.mealType == MealType.dinner);
      expect(dinnerMeal1.recipe.id, equals(customRecipe.id));

      // Session 2: Fresh restart
      final storage2 = LocalStorageService();
      final recipeRepo2 = JsonRecipeRepository(localStorageService: storage2);
      await recipeRepo2.getRecipes();

      final plannerRepo2 = MockMealPlanRepository(
        recipeRepo: recipeRepo2,
        localStorageService: storage2,
      );

      final mondayMeals2 = await plannerRepo2.getMealsForDate(date);
      final dinnerMeal2 = mondayMeals2.firstWhere((m) => m.mealType == MealType.dinner);

      expect(dinnerMeal2.recipe.id, equals(customRecipe.id),
          reason: 'Assigned meal recipe ID must persist after restart');
      expect(dinnerMeal2.mealType, equals(MealType.dinner));
    });

    test('Ingredient checklist state persists across sessions', () async {
      final storage1 = LocalStorageService();
      const recipeId = 'qm_01';

      // Save ingredient checkboxes
      await storage1.saveCheckedIngredients(recipeId, {0, 1, 3});

      // Session 2: User reopens recipe
      final storage2 = LocalStorageService();
      final restoredChecked = await storage2.getCheckedIngredients(recipeId);
      expect(restoredChecked, equals({0, 1, 3}));

      // Reset checklist
      await storage2.resetCheckedIngredients(recipeId);

      // Session 3: Reopen again
      final storage3 = LocalStorageService();
      final resetChecked = await storage3.getCheckedIngredients(recipeId);
      expect(resetChecked, isEmpty);
    });
  });
}
