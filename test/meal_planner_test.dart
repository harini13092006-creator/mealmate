import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mateapp/data/repositories/json_recipe_repository.dart';
import 'package:meal_mateapp/data/repositories/mock_meal_plan_repository.dart';
import 'package:meal_mateapp/domain/models/meal_plan.dart';
import 'package:meal_mateapp/domain/models/recipe.dart';
import 'package:meal_mateapp/domain/repositories/meal_plan_repository.dart';
import 'package:meal_mateapp/domain/repositories/recipe_repository.dart';
import 'package:meal_mateapp/ui/features/meal_planner/meal_planner_screen.dart';
import 'package:meal_mateapp/ui/features/meal_planner/meal_planner_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Provider.debugCheckInvalidValueType = null;
    SharedPreferences.setMockInitialValues({});
  });

  group('MealPlan Model Tests', () {
    test('PlannedMeal correctly populates date, day, mealType, recipeId, and recipe', () {
      final date = DateTime(2026, 11, 23); // Monday
      const dummyRecipe = Recipe(
        id: 'qm_01',
        title: 'Garlic Butter Shrimp Pasta',
        description: 'Delicious pasta',
        imageUrl: 'http://example.com/img.jpg',
        prepTimeMinutes: 5,
        cookTimeMinutes: 10,
        servings: 2,
        categories: ['Quick Meals'],
        ingredients: ['Pasta', 'Shrimp'],
        instructions: ['Boil pasta', 'Cook shrimp'],
        nutrition: NutritionInfo(calories: 450, proteinGrams: 30, carbsGrams: 45, fatGrams: 12),
      );

      final meal = PlannedMeal(
        id: 'plan_1',
        date: date,
        mealType: MealType.breakfast,
        recipe: dummyRecipe,
      );

      expect(meal.id, equals('plan_1'));
      expect(meal.date, equals(date));
      expect(meal.day, equals('Monday'));
      expect(meal.mealType, equals(MealType.breakfast));
      expect(meal.recipeId, equals('qm_01'));
      expect(meal.recipe.name, equals('Garlic Butter Shrimp Pasta'));
      expect(meal.isCompleted, isFalse);
    });
  });

  group('MealPlannerViewModel Weekly Navigation & Operations', () {
    late RecipeRepository recipeRepo;
    late MealPlanRepository mealPlanRepo;
    late MealPlannerViewModel viewModel;

    setUp(() async {
      recipeRepo = JsonRecipeRepository();
      await recipeRepo.getRecipes();
      mealPlanRepo = MockMealPlanRepository(recipeRepo: recipeRepo);
      viewModel = MealPlannerViewModel(
        mealPlanRepository: mealPlanRepo,
        recipeRepository: recipeRepo,
      );
      await viewModel.loadPlannerData();
    });

    test('Generates all 7 days of the week starting from Monday', () {
      final days = viewModel.weekDays;
      expect(days.length, equals(7));
      expect(days.first.weekday, equals(DateTime.monday));
      expect(days.last.weekday, equals(DateTime.sunday));
    });

    test('Next week and previous week adjust current week and dates by 7 days', () {
      final initialMonday = viewModel.currentWeekStart;

      viewModel.nextWeek();
      expect(viewModel.currentWeekStart, equals(initialMonday.add(const Duration(days: 7))));

      viewModel.previousWeek();
      expect(viewModel.currentWeekStart, equals(initialMonday));
    });

    test('Add meal, replace meal, and remove meal update planned meals correctly', () async {
      final monday = viewModel.currentWeekStart;
      final recipes = await recipeRepo.getRecipes();
      final recipe1 = recipes[0];
      final recipe2 = recipes[1];

      // Add meal to Dinner on Monday
      await viewModel.addMeal(MealType.dinner, recipe1, date: monday);
      var dinnerMeal = viewModel.getMealForSlot(MealType.dinner, date: monday);
      expect(dinnerMeal, isNotNull);
      expect(dinnerMeal!.recipe.id, equals(recipe1.id));

      // Replace meal with recipe2
      await viewModel.replaceMeal(dinnerMeal.id, recipe2);
      dinnerMeal = viewModel.getMealForSlot(MealType.dinner, date: monday);
      expect(dinnerMeal!.recipe.id, equals(recipe2.id));

      // Remove meal
      await viewModel.removeMeal(dinnerMeal.id);
      dinnerMeal = viewModel.getMealForSlot(MealType.dinner, date: monday);
      expect(dinnerMeal, isNull);
    });
  });

  group('MealPlannerScreen Widget Tests', () {
    late RecipeRepository recipeRepo;
    late MealPlanRepository mealPlanRepo;

    setUp(() async {
      recipeRepo = JsonRecipeRepository();
      await recipeRepo.getRecipes();
      mealPlanRepo = MockMealPlanRepository(recipeRepo: recipeRepo);
      await mealPlanRepo.getMealsForDate(DateTime.now());
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          Provider<RecipeRepository>.value(value: recipeRepo),
          Provider<MealPlanRepository>.value(value: mealPlanRepo),
          ChangeNotifierProvider(
            create: (_) => MealPlannerViewModel(
              mealPlanRepository: mealPlanRepo,
              recipeRepository: recipeRepo,
            ),
          ),
        ],
        child: const MaterialApp(
          home: MealPlannerScreen(),
        ),
      );
    }

    testWidgets('Renders 7 days, week navigation, overview, and 3 meal slots', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();

      // Title & Today action
      expect(find.text('Weekly Meal Planner'), findsOneWidget);
      expect(find.text('Today'), findsOneWidget);

      // Week navigation arrows
      expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);

      // 7-day strip check (Monday through Sunday)
      expect(find.text('MON'), findsOneWidget);
      expect(find.text('TUE'), findsOneWidget);
      expect(find.text('WED'), findsOneWidget);
      expect(find.text('THU'), findsOneWidget);
      expect(find.text('FRI'), findsOneWidget);
      expect(find.text('SAT'), findsOneWidget);
      expect(find.text('SUN'), findsOneWidget);

      // Weekly overview status
      expect(find.text('Weekly Plan Status'), findsOneWidget);

      // 3 meal slots are present
      expect(find.text('Breakfast'), findsOneWidget);
      expect(find.text('Lunch'), findsOneWidget);
      expect(find.text('Dinner'), findsOneWidget);
    });

    testWidgets('Tapping Add opens recipe picker and assigns recipe', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();

      // Find an 'Add' or 'Add Breakfast/Lunch/Dinner' button
      final addBtn = find.textContaining('Add ').first;
      await tester.tap(addBtn);
      await tester.pumpAndSettle();

      // Recipe Picker bottom sheet should appear with search and categories
      expect(find.text('Search 24+ recipes by name...'), findsOneWidget);
      expect(find.text('Assign'), findsAtLeastNWidgets(1));

      // Tap 'Assign' on first available recipe
      await tester.tap(find.text('Assign').first);
      await tester.pumpAndSettle();

      // Sheet closed and meal is assigned
      expect(find.text('Search 24+ recipes by name...'), findsNothing);
    });
  });
}
