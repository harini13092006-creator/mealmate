import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mateapp/data/repositories/json_recipe_repository.dart';
import 'package:meal_mateapp/domain/repositories/recipe_repository.dart';
import 'package:meal_mateapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Recipe Database (recipes.json) Tests', () {
    late RecipeRepository recipeRepository;

    setUp(() {
      recipeRepository = JsonRecipeRepository();
    });

    test('Loads 120 Indian recipes plus compatible legacy entries from bundled JSON', () async {
      final recipes = await recipeRepository.getRecipes();
      expect(recipes.where((r) => r.id.startsWith('ind_')).length, greaterThanOrEqualTo(120));
    });

    test('Contains all four expanded recipe categories', () async {
      final recipes = await recipeRepository.getRecipes();

      final quickMeals = recipes.where((r) => r.category == 'Quick Meals').toList();
      final healthyBowls = recipes.where((r) => r.category == 'Healthy Bowls').toList();
      final desserts = recipes.where((r) => r.category == 'Desserts').toList();

      final traditional = recipes.where((r) => r.category == 'Traditional Indian Dishes');
      expect(quickMeals.length, greaterThanOrEqualTo(30));
      expect(healthyBowls.length, greaterThanOrEqualTo(20));
      expect(desserts.length, greaterThanOrEqualTo(26));
      expect(traditional.length, greaterThanOrEqualTo(34));
    });

    test('All recipes contain valid complete fields', () async {
      final recipes = await recipeRepository.getRecipes();

      for (final r in recipes) {
        expect(r.id.isNotEmpty, isTrue);
        expect(r.name.isNotEmpty, isTrue);
        expect(r.category.isNotEmpty, isTrue);
        expect(r.description.isNotEmpty, isTrue);
        expect(r.prepTimeMinutes, greaterThanOrEqualTo(0));
        expect(r.cookTimeMinutes, greaterThanOrEqualTo(0));
        expect(r.difficultyLevel.isNotEmpty, isTrue);
        expect(r.servings, greaterThan(0));
        expect(r.ingredients.isNotEmpty, isTrue);
        expect(r.instructions.isNotEmpty, isTrue);
        expect(r.imageUrl.startsWith('http') || r.imageUrl.startsWith('assets/images/recipes/'), isTrue);
        expect(r.nutrition.calories, greaterThan(0));
        expect(r.nutrition.proteinGrams, greaterThanOrEqualTo(0));
        expect(r.nutrition.carbsGrams, greaterThanOrEqualTo(0));
        expect(r.nutrition.fatGrams, greaterThanOrEqualTo(0));
      }
    });

    test('Search recipes dynamically by name works', () async {
      final shrimpResults = await recipeRepository.searchRecipes('Shrimp');
      expect(shrimpResults.length, greaterThanOrEqualTo(1));
      expect(shrimpResults.first.name, contains('Shrimp'));

      final lavaCakeResults = await recipeRepository.searchRecipes('Lava Cake');
      expect(lavaCakeResults.length, equals(1));
      expect(lavaCakeResults.first.category, equals('Desserts'));
    });

    test('Filtering by category works as expected', () async {
      final dessertsOnly = await recipeRepository.searchRecipes('', category: 'Desserts');
      expect(dessertsOnly.length, greaterThanOrEqualTo(26));
      for (final r in dessertsOnly) {
        expect(r.category, equals('Desserts'));
      }
    });
  });

  group('Home Screen UI & Integration Tests', () {
    testWidgets('Renders complete home screen with logo, greeting, search, categories, and cards', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MealMateApp());

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();

      // 1. Logo and App Name
      expect(find.text('Mealmate'), findsAtLeastNWidgets(1));

      // 2. Greeting section
      expect(find.text('Hello, Chef! 👋'), findsOneWidget);

      // 3. Search Bar
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search 120+ Indian recipes by name or ingredient...'), findsOneWidget);

      // 4. Featured Recipes section
      expect(find.text('Featured Recipes'), findsOneWidget);

      // 5. Horizontal Categories
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Quick Meals'), findsAtLeastNWidgets(1));
      expect(find.text('Healthy Bowls'), findsAtLeastNWidgets(1));
      expect(find.text('Desserts'), findsAtLeastNWidgets(1));
    });

    testWidgets('Dynamic search updates displayed recipes', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MealMateApp());

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();

      // Enter search query
      final searchField = find.byType(TextField);
      await tester.enterText(searchField, 'Shrimp');

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      // Shrimp pasta should be displayed
      expect(find.text('15-Minute Garlic Butter Shrimp Pasta'), findsOneWidget);
    });

    testWidgets('Category filtering updates displayed recipes', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MealMateApp());

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();

      // Tap on 'Desserts' category chip
      final dessertsChip = find.text('Desserts').first;
      await tester.tap(dessertsChip);

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      await tester.pump();

      // Desserts should be displayed
      expect(find.text('Gulab Jamun'), findsOneWidget);
    });
  });
}
