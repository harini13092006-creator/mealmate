import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mateapp/data/repositories/json_recipe_repository.dart';
import 'package:meal_mateapp/domain/models/grocery_item.dart';
import 'package:meal_mateapp/domain/models/meal_plan.dart';
import 'package:meal_mateapp/domain/models/recipe.dart';
import 'package:meal_mateapp/domain/repositories/grocery_repository.dart';
import 'package:meal_mateapp/domain/repositories/meal_plan_repository.dart';
import 'package:meal_mateapp/domain/repositories/recipe_repository.dart';
import 'package:meal_mateapp/ui/features/groceries/groceries_view_model.dart';
import 'package:meal_mateapp/ui/features/meal_planner/meal_planner_view_model.dart';
import 'package:meal_mateapp/ui/features/recipes/recipe_detail_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Provider.debugCheckInvalidValueType = null;
    SharedPreferences.setMockInitialValues({});
  });

  group('Ingredient Parser Unit Tests', () {
    test('Correctly extracts quantity and ingredient name', () {
      final p1 = ParsedIngredient.fromString('8 oz Angel Hair Pasta');
      expect(p1.quantity, equals('8 oz'));
      expect(p1.name, equals('Angel Hair Pasta'));

      final p2 = ParsedIngredient.fromString('1/2 lb Large Shrimp peeled and deveined');
      expect(p2.quantity, equals('1/2 lb'));
      expect(p2.name, equals('Large Shrimp peeled and deveined'));

      final p3 = ParsedIngredient.fromString('3 tbsp Unsalted Butter');
      expect(p3.quantity, equals('3 tbsp'));
      expect(p3.name, equals('Unsalted Butter'));

      final p4 = ParsedIngredient.fromString('Salt and black pepper to taste');
      expect(p4.quantity, equals('To taste'));
      expect(p4.name, equals('Salt and black pepper'));

      final p5 = ParsedIngredient.fromString('Pinch of Italian seasoning');
      expect(p5.quantity, equals('Pinch'));
      expect(p5.name, equals('Italian seasoning'));
    });
  });

  group('RecipeDetailScreen Widget Tests', () {
    late RecipeRepository recipeRepo;

    setUp(() async {
      recipeRepo = JsonRecipeRepository();
      await recipeRepo.getRecipes(); // Warm cache
    });

    Widget createTestWidget(String recipeId) {
      return MultiProvider(
        providers: [
          Provider<RecipeRepository>.value(value: recipeRepo),
          ChangeNotifierProvider(
            create: (_) => GroceriesViewModel(
              groceryRepository: _MockGroceryRepo(),
            ),
          ),
          ChangeNotifierProvider(
            create: (_) => MealPlannerViewModel(
              mealPlanRepository: _MockMealPlanRepo(),
              recipeRepository: recipeRepo,
            ),
          ),
        ],
        child: MaterialApp(
          home: RecipeDetailScreen(recipeId: recipeId),
        ),
      );
    }

    testWidgets('Renders all recipe details (name, highlights, nutrition, instructions)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget('qm_01'));

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      // Recipe name
      expect(find.text('15-Minute Garlic Butter Shrimp Pasta'), findsAtLeastNWidgets(1));

      // Highlights
      expect(find.text('Prep Time'), findsOneWidget);
      expect(find.text('5m'), findsOneWidget);
      expect(find.text('Cook Time'), findsOneWidget);
      expect(find.text('10m'), findsOneWidget);
      expect(find.text('Servings'), findsOneWidget);

      // Nutrition section
      expect(find.text('Nutritional Information'), findsOneWidget);
      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('Fat'), findsOneWidget);

      // Ingredients Checklist section
      expect(find.text('Ingredients Checklist'), findsOneWidget);
      expect(find.text('0 of 9 ingredients ready (0%)'), findsOneWidget);

      // Cooking Instructions with numbered cards
      expect(find.text('Cooking Instructions'), findsOneWidget);
      expect(find.text('Step 1'), findsOneWidget);
      expect(find.text('Step 2'), findsOneWidget);
      expect(find.text('Step 3'), findsOneWidget);

      // Favorite button
      expect(find.byIcon(Icons.bookmark_border_rounded), findsOneWidget);
    });

    testWidgets('Interactive ingredient checklist toggling, progress, and reset', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget('qm_01'));

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      // Initially 0 checked
      expect(find.text('0 of 9 ingredients ready (0%)'), findsOneWidget);
      expect(find.text('Reset'), findsNothing);

      // Tap first ingredient checkbox
      final firstCheckbox = find.byType(Checkbox).first;
      await tester.tap(firstCheckbox);
      await tester.pump();

      // Progress updates to 1 of 9 (11%)
      expect(find.text('1 of 9 ingredients ready (11%)'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Tap second ingredient checkbox
      final secondCheckbox = find.byType(Checkbox).at(1);
      await tester.tap(secondCheckbox);
      await tester.pump();

      // Progress updates to 2 of 9 (22%)
      expect(find.text('2 of 9 ingredients ready (22%)'), findsOneWidget);

      // Tap Reset button
      await tester.tap(find.text('Reset'));
      await tester.pump();

      // All ingredients reset to 0
      expect(find.text('0 of 9 ingredients ready (0%)'), findsOneWidget);
      expect(find.text('Reset'), findsNothing);
    });

    testWidgets('Toggling favorite maintains active checklist state without reset', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget('qm_01'));

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      // Check an ingredient first
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();
      expect(find.text('1 of 9 ingredients ready (11%)'), findsOneWidget);

      // Tap favorite/bookmark button
      final bookmarkBtn = find.byIcon(Icons.bookmark_border_rounded);
      await tester.tap(bookmarkBtn);
      await tester.pump();

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Bookmark changed to saved state
      expect(find.byIcon(Icons.bookmark_rounded), findsOneWidget);

      // Verify checklist state was preserved!
      expect(find.text('1 of 9 ingredients ready (11%)'), findsOneWidget);
    });
  });
}

class _MockGroceryRepo implements GroceryRepository {
  @override
  Future<void> addIngredientsFromRecipe(String recipeTitle, List<String> ingredients) async {}
  @override
  Future<void> addItem(dynamic item) async {}
  @override
  Future<void> clearCheckedItems() async {}
  @override
  Future<List<GroceryItem>> getItems() async => [];
  @override
  Future<void> removeItem(String id) async {}
  @override
  Future<void> toggleItemChecked(String id) async {}
}

class _MockMealPlanRepo implements MealPlanRepository {
  @override
  Future<void> addMealPlan({required DateTime date, required MealType mealType, required Recipe recipe}) async {}
  @override
  Future<List<PlannedMeal>> getMealsForDate(DateTime date) async => [];
  @override
  Future<List<PlannedMeal>> getMealsForWeek(DateTime startOfWeek) async => [];
  @override
  Future<void> replaceMealPlan({required String mealId, required Recipe newRecipe}) async {}
  @override
  Future<void> removeMealPlan(String mealId) async {}
  @override
  Future<void> toggleMealCompleted(String mealId) async {}
  @override
  Future<void> clearAllMealPlans() async {}
}
