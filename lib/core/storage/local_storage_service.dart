import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Centralized service managing offline local persistence via SharedPreferences.
///
/// Features:
/// - Structured JSON serialization for complex objects.
/// - Resilient error handling for missing keys, corrupted JSON, and empty collections.
/// - Supports dependency injection of [SharedPreferences] for easy unit testing.
class LocalStorageService {
  SharedPreferences? _prefs;

  LocalStorageService([this._prefs]);

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==========================================
  // PART 2: Favorite Recipes
  // ==========================================

  /// Retrieves list of favorite recipe IDs from local storage.
  /// Falls back to an empty list on missing values or corrupt data.
  Future<List<String>> getFavoriteRecipeIds() async {
    try {
      final prefs = await _getPrefs();
      // Try reading as JSON string first
      final raw = prefs.getString(AppConstants.favoriteRecipeIdsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          return decoded.map((e) => e.toString()).toList();
        }
      }

      // Fallback check for standard string list if previously saved that way
      final list = prefs.getStringList(AppConstants.favoriteRecipeIdsKey);
      if (list != null) {
        return List<String>.from(list);
      }
    } catch (_) {
      // In case of corrupt JSON, return safe empty list
    }
    return [];
  }

  /// Persists the list of favorite recipe IDs.
  Future<void> saveFavoriteRecipeIds(List<String> ids) async {
    final prefs = await _getPrefs();
    final jsonString = jsonEncode(ids);
    await prefs.setString(AppConstants.favoriteRecipeIdsKey, jsonString);
  }

  /// Checks if a specific recipe ID is bookmarked.
  Future<bool> isFavorite(String recipeId) async {
    final favorites = await getFavoriteRecipeIds();
    return favorites.contains(recipeId);
  }

  /// Toggles favorite status for a recipe ID and returns the new status.
  Future<bool> toggleFavoriteRecipeId(String recipeId) async {
    final favorites = await getFavoriteRecipeIds();
    final isFav = favorites.contains(recipeId);
    if (isFav) {
      favorites.remove(recipeId);
    } else {
      favorites.add(recipeId);
    }
    await saveFavoriteRecipeIds(favorites);
    return !isFav;
  }

  /// Clears all saved favorite recipe IDs.
  Future<void> clearFavorites() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConstants.favoriteRecipeIdsKey);
  }

  // ==========================================
  // PART 3: Weekly Meal Plans
  // ==========================================

  /// Retrieves stored weekly meal plans as raw JSON maps.
  /// Returns empty list if missing or corrupted.
  Future<List<Map<String, dynamic>>> getMealPlansJson() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(AppConstants.weeklyMealPlansKey);
      if (raw == null || raw.trim().isEmpty) {
        return [];
      }
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {
      // Return empty list on parse failure
    }
    return [];
  }

  /// Persists weekly meal plans list in structured JSON.
  Future<void> saveMealPlansJson(List<Map<String, dynamic>> mealPlans) async {
    final prefs = await _getPrefs();
    final jsonString = jsonEncode(mealPlans);
    await prefs.setString(AppConstants.weeklyMealPlansKey, jsonString);
  }

  /// Clears stored meal plans.
  Future<void> clearMealPlans() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConstants.weeklyMealPlansKey);
  }

  // ==========================================
  // PART 4: Ingredient Checklists
  // ==========================================

  /// Retrieves checked ingredient indices for a specific recipe.
  Future<Set<int>> getCheckedIngredients(String recipeId) async {
    try {
      final all = await getAllCheckedIngredients();
      final indices = all[recipeId];
      if (indices != null) {
        return indices.toSet();
      }
    } catch (_) {
      // Fallback to empty set
    }
    return {};
  }

  /// Persists checked ingredient indices for a specific recipe.
  Future<void> saveCheckedIngredients(String recipeId, Set<int> indices) async {
    final all = await getAllCheckedIngredients();
    if (indices.isEmpty) {
      all.remove(recipeId);
    } else {
      all[recipeId] = indices.toList();
    }
    final prefs = await _getPrefs();
    await prefs.setString(AppConstants.ingredientChecklistsKey, jsonEncode(all));
  }

  /// Resets the checklist for a specific recipe.
  Future<void> resetCheckedIngredients(String recipeId) async {
    final all = await getAllCheckedIngredients();
    if (all.containsKey(recipeId)) {
      all.remove(recipeId);
      final prefs = await _getPrefs();
      await prefs.setString(AppConstants.ingredientChecklistsKey, jsonEncode(all));
    }
  }

  /// Clears all ingredient checklists across all recipes.
  Future<void> clearAllIngredientChecklists() async {
    final prefs = await _getPrefs();
    await prefs.remove(AppConstants.ingredientChecklistsKey);
  }

  /// Retrieves the entire ingredient checklists map {recipeId: [0, 1, 3]}.
  Future<Map<String, List<int>>> getAllCheckedIngredients() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(AppConstants.ingredientChecklistsKey);
      if (raw == null || raw.trim().isEmpty) {
        return {};
      }
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        final result = <String, List<int>>{};
        decoded.forEach((key, value) {
          if (value is List) {
            result[key.toString()] = value
                .map((e) => int.tryParse(e.toString()))
                .whereType<int>()
                .toList();
          }
        });
        return result;
      }
    } catch (_) {
      // Fallback
    }
    return {};
  }
}
