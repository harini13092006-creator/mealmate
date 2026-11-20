import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../../core/responsive_layout.dart';
import '../favorites/favorites_view_model.dart';
import '../meal_planner/meal_planner_view_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required Future<void> Function() onConfirm,
    bool isDestructive = true,
  }) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: isDestructive
                ? FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                    foregroundColor: theme.colorScheme.onError,
                  )
                : null,
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await onConfirm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeNotifier = context.watch<ThemeNotifier>();
    final localStorage = context.read<LocalStorageService>();
    final recipeRepo = context.read<RecipeRepository>();
    final favoritesVM = context.read<FavoritesViewModel>();
    final mealPlannerVM = context.read<MealPlannerViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ResponsiveContent(
        maxWidth: 900,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Application Branding Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        size: 34,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Version 1.0.0',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Smart Weekly Meal Planner & Recipes',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: Appearance & Theme
            Text(
              'Appearance',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: RadioGroup<ThemeMode>(
                groupValue: themeNotifier.themeMode,
                onChanged: (mode) {
                  if (mode != null) themeNotifier.setThemeMode(mode);
                },
                child: Column(
                  children: const [
                    RadioListTile<ThemeMode>(
                      title: Text('System Default'),
                      subtitle: Text('Matches your Android device settings'),
                      value: ThemeMode.system,
                    ),
                    Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: Text('Light Theme'),
                      subtitle: Text('Clean bright appearance'),
                      value: ThemeMode.light,
                    ),
                    Divider(height: 1),
                    RadioListTile<ThemeMode>(
                      title: Text('Dark Theme'),
                      subtitle: Text('Easy on eyes in low light conditions'),
                      value: ThemeMode.dark,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: Data Management (Destructive Actions)
            Text(
              'Data & Storage',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  // Reset ingredient checklists
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue.withValues(alpha: 0.12),
                      child: const Icon(
                        Icons.checklist_rtl_rounded,
                        color: Colors.blue,
                      ),
                    ),
                    title: const Text('Reset Ingredient Checklists'),
                    subtitle: const Text(
                      'Uncheck all ingredients across all recipes',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      _showConfirmDialog(
                        context: context,
                        title: 'Reset Ingredient Checklists?',
                        message: 'This will reset all checked ingredients across all recipes to unchecked. This action cannot be undone.',
                        confirmLabel: 'Reset',
                        onConfirm: () async {
                          await localStorage.clearAllIngredientChecklists();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'All ingredient checklists have been reset.',
                                ),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),

                  // Clear saved meal plans
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.orange.withValues(alpha: 0.12),
                      child: const Icon(
                        Icons.delete_sweep_rounded,
                        color: Colors.orange,
                      ),
                    ),
                    title: const Text('Clear Saved Meal Plans'),
                    subtitle: const Text(
                      'Remove all breakfast, lunch, and dinner entries',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      _showConfirmDialog(
                        context: context,
                        title: 'Clear Saved Meal Plans?',
                        message: 'Are you sure you want to clear all planned meals for the week? This action cannot be undone.',
                        confirmLabel: 'Clear Plans',
                        onConfirm: () async {
                          await mealPlannerVM.clearAllMeals();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Weekly meal plans cleared.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                  const Divider(height: 1),

                  // Clear favorites
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.red.withValues(alpha: 0.12),
                      child: const Icon(
                        Icons.heart_broken_rounded,
                        color: Colors.red,
                      ),
                    ),
                    title: const Text('Clear Favorites'),
                    subtitle: const Text(
                      'Remove all bookmarked favorite recipes',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () {
                      _showConfirmDialog(
                        context: context,
                        title: 'Clear All Favorites?',
                        message: 'Are you sure you want to remove all saved favorites? This action cannot be undone.',
                        confirmLabel: 'Clear Favorites',
                        onConfirm: () async {
                          await recipeRepo.clearAllFavorites();
                          await favoritesVM.loadFavorites();
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Favorites have been cleared.'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: About Mealmate
            Text(
              'About Mealmate',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About Mealmate',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Mealmate is your personal culinary companion designed to make healthy eating, recipe discovery, and weekly meal planning effortless. Built with clean architecture, offline-first persistence, and Material 3 design.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.8,
                        ),
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '24+ Curated recipes with full nutrition facts',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Interactive ingredients checklist & progress',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '7-Day weekly meal scheduling (Breakfast, Lunch, Dinner)',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            '100% Offline persistent local storage',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
