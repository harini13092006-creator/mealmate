import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mateapp/core/constants/app_constants.dart';
import 'package:meal_mateapp/core/storage/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LocalStorageService Unit Tests', () {
    late LocalStorageService storage;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorageService();
    });

    test('Favorite Recipes - save and retrieve', () async {
      // Empty initially
      expect(await storage.getFavoriteRecipeIds(), isEmpty);
      expect(await storage.isFavorite('recipe_1'), isFalse);

      // Save list
      await storage.saveFavoriteRecipeIds(['recipe_1', 'recipe_2']);
      final favs = await storage.getFavoriteRecipeIds();
      expect(favs, equals(['recipe_1', 'recipe_2']));
      expect(await storage.isFavorite('recipe_1'), isTrue);
      expect(await storage.isFavorite('recipe_3'), isFalse);

      // Toggle off
      final isNowFav1 = await storage.toggleFavoriteRecipeId('recipe_1');
      expect(isNowFav1, isFalse);
      expect(await storage.isFavorite('recipe_1'), isFalse);

      // Toggle on
      final isNowFav3 = await storage.toggleFavoriteRecipeId('recipe_3');
      expect(isNowFav3, isTrue);
      expect(await storage.isFavorite('recipe_3'), isTrue);
    });

    test('Favorite Recipes - resilient to invalid JSON', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.favoriteRecipeIdsKey: 'corrupted{invalid json',
      });
      storage = LocalStorageService();

      final favs = await storage.getFavoriteRecipeIds();
      expect(favs, isEmpty);
    });

    test('Weekly Meal Plans - save, retrieve and clear', () async {
      expect(await storage.getMealPlansJson(), isEmpty);

      final dummyPlans = [
        {
          'id': 'plan_01',
          'date': '2026-11-23T00:00:00.000',
          'day': 'Monday',
          'mealType': 'breakfast',
          'recipeId': 'qm_01',
          'isCompleted': false,
        },
        {
          'id': 'plan_02',
          'date': '2026-11-23T00:00:00.000',
          'day': 'Monday',
          'mealType': 'dinner',
          'recipeId': 'qm_02',
          'isCompleted': true,
        },
      ];

      await storage.saveMealPlansJson(dummyPlans);
      final retrieved = await storage.getMealPlansJson();
      expect(retrieved.length, equals(2));
      expect(retrieved.first['id'], equals('plan_01'));
      expect(retrieved.first['mealType'], equals('breakfast'));
      expect(retrieved.last['isCompleted'], isTrue);

      // Clear
      await storage.clearMealPlans();
      expect(await storage.getMealPlansJson(), isEmpty);
    });

    test('Weekly Meal Plans - resilient to corrupt JSON', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.weeklyMealPlansKey: '{{not a json list',
      });
      storage = LocalStorageService();

      expect(await storage.getMealPlansJson(), isEmpty);
    });

    test('Ingredient Checklists - save, retrieve and reset per recipe', () async {
      expect(await storage.getCheckedIngredients('recipe_1'), isEmpty);

      // Save checked ingredients for recipe_1
      await storage.saveCheckedIngredients('recipe_1', {0, 2, 4});
      // Save checked ingredients for recipe_2
      await storage.saveCheckedIngredients('recipe_2', {1, 3});

      final checked1 = await storage.getCheckedIngredients('recipe_1');
      final checked2 = await storage.getCheckedIngredients('recipe_2');

      expect(checked1, equals({0, 2, 4}));
      expect(checked2, equals({1, 3}));

      // Reset recipe_1
      await storage.resetCheckedIngredients('recipe_1');
      expect(await storage.getCheckedIngredients('recipe_1'), isEmpty);
      // recipe_2 remains intact
      expect(await storage.getCheckedIngredients('recipe_2'), equals({1, 3}));
    });

    test('Ingredient Checklists - resilient to corrupt JSON', () async {
      SharedPreferences.setMockInitialValues({
        AppConstants.ingredientChecklistsKey: 'invalid json content',
      });
      storage = LocalStorageService();

      expect(await storage.getCheckedIngredients('recipe_1'), isEmpty);
    });
  });
}
