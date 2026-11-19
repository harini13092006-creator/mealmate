import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mateapp/core/storage/local_storage_service.dart';
import 'package:meal_mateapp/core/theme/theme_notifier.dart';
import 'package:meal_mateapp/data/repositories/json_recipe_repository.dart';
import 'package:meal_mateapp/data/repositories/mock_meal_plan_repository.dart';
import 'package:meal_mateapp/domain/repositories/meal_plan_repository.dart';
import 'package:meal_mateapp/domain/repositories/recipe_repository.dart';
import 'package:meal_mateapp/ui/features/favorites/favorites_view_model.dart';
import 'package:meal_mateapp/ui/features/meal_planner/meal_planner_view_model.dart';
import 'package:meal_mateapp/ui/features/settings/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsScreen Widget & Quality Assurance Tests', () {
    late LocalStorageService storage;
    late JsonRecipeRepository recipeRepo;
    late MockMealPlanRepository mealPlanRepo;

    setUp(() async {
      Provider.debugCheckInvalidValueType = null;
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorageService();
      recipeRepo = JsonRecipeRepository(localStorageService: storage);
      await recipeRepo.getRecipes();
      mealPlanRepo = MockMealPlanRepository(
        recipeRepo: recipeRepo,
        localStorageService: storage,
      );
    });

    Widget createSettingsTestWidget() {
      return MultiProvider(
        providers: [
          Provider<LocalStorageService>.value(value: storage),
          Provider<RecipeRepository>.value(value: recipeRepo),
          Provider<MealPlanRepository>.value(value: mealPlanRepo),
          ChangeNotifierProvider(create: (_) => ThemeNotifier()),
          ChangeNotifierProvider(
            create: (_) => FavoritesViewModel(recipeRepository: recipeRepo),
          ),
          ChangeNotifierProvider(
            create: (_) => MealPlannerViewModel(
              mealPlanRepository: mealPlanRepo,
              recipeRepository: recipeRepo,
            ),
          ),
        ],
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      );
    }

    testWidgets('Renders app name, version, theme preferences, and about section', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSettingsTestWidget());
      await tester.pump();

      // App name and version
      expect(find.text('Mealmate'), findsAtLeastNWidgets(1));
      expect(find.text('Version 1.0.0'), findsOneWidget);

      // Appearance options
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('System Default'), findsOneWidget);
      expect(find.text('Light Theme'), findsOneWidget);
      expect(find.text('Dark Theme'), findsOneWidget);

      // Data options
      expect(find.text('Reset Ingredient Checklists'), findsOneWidget);
      expect(find.text('Clear Saved Meal Plans'), findsOneWidget);
      expect(find.text('Clear Favorites'), findsOneWidget);

      // About section
      expect(find.text('About Mealmate'), findsAtLeastNWidgets(1));
      expect(find.textContaining('culinary companion'), findsOneWidget);
    });

    testWidgets('Tapping Reset Checklists displays confirmation dialog and dismisses on cancel', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSettingsTestWidget());
      await tester.pump();

      await tester.tap(find.text('Reset Ingredient Checklists'));
      await tester.pump();

      // Dialog is shown
      expect(find.text('Reset Ingredient Checklists?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);

      // Cancel button dismisses
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(find.text('Reset Ingredient Checklists?'), findsNothing);
    });

    testWidgets('Tapping Clear Favorites displays confirmation dialog and clears on confirm', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSettingsTestWidget());
      await tester.pump();

      await tester.tap(find.text('Clear Favorites'));
      await tester.pump();

      // Dialog is shown
      expect(find.text('Clear All Favorites?'), findsOneWidget);

      // Confirm button in dialog clears
      final dialogClearButton = find.widgetWithText(FilledButton, 'Clear Favorites');
      expect(dialogClearButton, findsOneWidget);
      await tester.tap(dialogClearButton);
      // Pump dialog dismiss animation
      await tester.pump(const Duration(milliseconds: 300));
      // Pump async onConfirm execution
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      // Pump SnackBar entrance
      await tester.pump(const Duration(milliseconds: 300));

      // SnackBar displayed
      expect(find.text('Favorites have been cleared.'), findsOneWidget);
    });

    testWidgets('Tapping Clear Saved Meal Plans displays confirmation dialog and clears on confirm', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createSettingsTestWidget());
      await tester.pump();

      await tester.tap(find.text('Clear Saved Meal Plans'));
      await tester.pump();

      // Dialog is shown
      expect(find.text('Clear Saved Meal Plans?'), findsOneWidget);

      // Confirm button clears
      await tester.tap(find.text('Clear Plans'));
      // Pump dialog dismiss animation
      await tester.pump(const Duration(milliseconds: 300));
      // Pump async onConfirm execution
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 100));
      });
      // Pump SnackBar entrance
      await tester.pump(const Duration(milliseconds: 300));

      // SnackBar displayed
      expect(find.text('Weekly meal plans cleared.'), findsOneWidget);
    });
  });
}
