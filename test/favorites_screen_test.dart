import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mateapp/core/storage/local_storage_service.dart';
import 'package:meal_mateapp/data/repositories/json_recipe_repository.dart';
import 'package:meal_mateapp/domain/repositories/recipe_repository.dart';
import 'package:meal_mateapp/ui/features/favorites/favorites_screen.dart';
import 'package:meal_mateapp/ui/features/favorites/favorites_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FavoritesScreen Widget & Synchronization Tests', () {
    late LocalStorageService storage;
    late JsonRecipeRepository recipeRepo;

    setUp(() async {
      Provider.debugCheckInvalidValueType = null;
      SharedPreferences.setMockInitialValues({});
      storage = LocalStorageService();
      recipeRepo = JsonRecipeRepository(localStorageService: storage);
      await recipeRepo.getRecipes(); // Pre-load
    });

    Widget createFavoritesTestWidget() {
      return MultiProvider(
        providers: [
          Provider<RecipeRepository>.value(value: recipeRepo),
          ChangeNotifierProvider(
            create: (_) => FavoritesViewModel(recipeRepository: recipeRepo),
          ),
        ],
        child: const MaterialApp(
          home: FavoritesScreen(),
        ),
      );
    }

    testWidgets('Renders empty state when no favorites exist', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createFavoritesTestWidget());
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      expect(find.text('Saved Favorites'), findsOneWidget);
      expect(find.text('No Favorite Recipes Yet'), findsOneWidget);
      expect(find.text('Explore Recipes'), findsOneWidget);
      expect(find.byIcon(Icons.favorite_border_rounded), findsOneWidget);
    });

    testWidgets('Renders bookmarked recipes and removes when favorite icon tapped', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Bookmark two recipes in real async zone
      await tester.runAsync(() async {
        await recipeRepo.toggleFavorite('qm_01');
        await recipeRepo.toggleFavorite('hb_01');
      });

      await tester.pumpWidget(createFavoritesTestWidget());
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      // Header shows 2 saved badge
      expect(find.text('2 saved'), findsOneWidget);
      expect(find.text('15-Minute Garlic Butter Shrimp Pasta'), findsOneWidget);
      expect(find.text('Mediterranean Quinoa Salad Bowl'), findsOneWidget);

      // Tap remove on the first recipe
      final removeButtons = find.byTooltip('Remove from favorites');
      expect(removeButtons, findsNWidgets(2));
      await tester.tap(removeButtons.first);
      await tester.pump();

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 300));
      });
      await tester.pump();

      // Now only 1 saved recipe remains
      expect(find.text('1 saved'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);

      // Clear SnackBars cleanly
      ScaffoldMessenger.of(tester.element(find.byType(FavoritesScreen))).clearSnackBars();
      await tester.pump(const Duration(milliseconds: 300));

    });

    testWidgets('Favorites remain synchronized with repository external changes', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createFavoritesTestWidget());
      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      // Initially empty
      expect(find.text('No Favorite Recipes Yet'), findsOneWidget);

      // External action in real async zone
      await tester.runAsync(() async {
        await recipeRepo.toggleFavorite('ds_01');
      });
      await tester.pump();

      await tester.runAsync(() async {
        await Future.delayed(const Duration(milliseconds: 200));
      });
      await tester.pump();

      // Automatically updates in FavoritesScreen without manual reload!
      expect(find.text('1 saved'), findsOneWidget);
      expect(find.text('Molten Chocolate Lava Cake'), findsOneWidget);
      expect(find.text('No Favorite Recipes Yet'), findsNothing);
    });
  });
}
