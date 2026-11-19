import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../ui/core/main_scaffold.dart';
import '../../ui/features/favorites/favorites_screen.dart';
import '../../ui/features/groceries/groceries_screen.dart';
import '../../ui/features/home/home_screen.dart';
import '../../ui/features/meal_planner/meal_planner_screen.dart';
import '../../ui/features/profile/profile_screen.dart';
import '../../ui/features/recipes/recipe_detail_screen.dart';
import '../../ui/features/recipes/recipes_screen.dart';
import '../../ui/features/settings/settings_screen.dart';
import '../theme/theme_notifier.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/home',
    routes: [
      // Direct recipe detail route over root navigator
      GoRoute(
        path: '/recipes/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return RecipeDetailScreen(recipeId: id);
        },
      ),
      // Standalone full recipe catalog route
      GoRoute(
        path: '/recipes',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const RecipesScreen(),
      ),
      // Standalone groceries screen
      GoRoute(
        path: '/groceries',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GroceriesScreen(),
      ),
      // Standalone profile screen
      GoRoute(
        path: '/profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final themeNotifier = context.watch<ThemeNotifier>();
          return ProfileScreen(
            currentThemeMode: themeNotifier.themeMode,
            onThemeModeChanged: (mode) => themeNotifier.setThemeMode(mode),
          );
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 1: Favorites
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/favorites',
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),
          // Branch 2: Meal Planner
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/planner',
                builder: (context, state) => const MealPlannerScreen(),
              ),
            ],
          ),
          // Branch 3: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
