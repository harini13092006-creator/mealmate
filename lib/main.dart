import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/storage/local_storage_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_notifier.dart';
import 'data/repositories/json_recipe_repository.dart';
import 'data/repositories/mock_grocery_repository.dart';
import 'data/repositories/mock_meal_plan_repository.dart';
import 'domain/repositories/grocery_repository.dart';
import 'domain/repositories/meal_plan_repository.dart';
import 'domain/repositories/recipe_repository.dart';
import 'ui/features/favorites/favorites_view_model.dart';
import 'ui/features/groceries/groceries_view_model.dart';
import 'ui/features/home/home_view_model.dart';
import 'ui/features/meal_planner/meal_planner_view_model.dart';
import 'ui/features/recipes/recipes_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Provider.debugCheckInvalidValueType = null;
  runApp(const MealMateApp());
}

class MealMateApp extends StatefulWidget {
  const MealMateApp({super.key});

  @override
  State<MealMateApp> createState() => _MealMateAppState();
}

class _MealMateAppState extends State<MealMateApp> {
  late final LocalStorageService _localStorageService;
  late final RecipeRepository _recipeRepository;
  late final MealPlanRepository _mealPlanRepository;
  late final GroceryRepository _groceryRepository;
  late final router = createAppRouter();

  @override
  void initState() {
    super.initState();
    Provider.debugCheckInvalidValueType = null;
    _localStorageService = LocalStorageService();
    final jsonRecipeRepo = JsonRecipeRepository(localStorageService: _localStorageService);
    _recipeRepository = jsonRecipeRepo;
    _mealPlanRepository = MockMealPlanRepository(
      recipeRepo: jsonRecipeRepo,
      localStorageService: _localStorageService,
    );
    _groceryRepository = MockGroceryRepository();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Storage & Theme
        Provider<LocalStorageService>.value(value: _localStorageService),
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),

        // Repositories
        Provider<RecipeRepository>.value(value: _recipeRepository),
        Provider<MealPlanRepository>.value(value: _mealPlanRepository),
        Provider<GroceryRepository>.value(value: _groceryRepository),

        // ViewModels
        ChangeNotifierProvider(
          create: (ctx) => HomeViewModel(
            recipeRepository: ctx.read<RecipeRepository>(),
            mealPlanRepository: ctx.read<MealPlanRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => RecipesViewModel(
            recipeRepository: ctx.read<RecipeRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => FavoritesViewModel(
            recipeRepository: ctx.read<RecipeRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => MealPlannerViewModel(
            mealPlanRepository: ctx.read<MealPlanRepository>(),
            recipeRepository: ctx.read<RecipeRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (ctx) => GroceriesViewModel(
            groceryRepository: ctx.read<GroceryRepository>(),
          ),
        ),
      ],
      child: Consumer<ThemeNotifier>(
        builder: (context, themeNotifier, _) {
          return MaterialApp.router(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeNotifier.themeMode,
            routerConfig: router,
          );
        },
      ),
    );
  }
}
