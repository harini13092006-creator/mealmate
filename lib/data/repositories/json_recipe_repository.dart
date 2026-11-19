import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../../core/storage/local_storage_service.dart';
import '../../domain/models/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

class JsonRecipeRepository extends ChangeNotifier implements RecipeRepository {
  final LocalStorageService _localStorageService;
  List<Recipe> _recipes = [];
  Future<void>? _loadFuture;

  JsonRecipeRepository({LocalStorageService? localStorageService})
    : _localStorageService = localStorageService ?? LocalStorageService();

  Future<void> _ensureLoaded() {
    _loadFuture ??= _loadData();
    return _loadFuture!;
  }

  Future<void> _loadData() async {
    try {
      final jsonString = await rootBundle.loadString('assets/recipes.json');
      final dynamic decoded = jsonDecode(jsonString);
      if (decoded is List) {
        final rawRecipes = decoded
            .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
            .toList();

        // Restore persisted favorite status
        final favIds = await _localStorageService.getFavoriteRecipeIds();
        final favSet = favIds.toSet();

        _recipes = rawRecipes
            .map((r) => r.copyWith(isFavorite: favSet.contains(r.id)))
            .toList();
      }
    } catch (e) {
      // Fallback or empty if error loading
      _recipes = [];
    }
  }

  @override
  Future<List<Recipe>> getRecipes() async {
    await _ensureLoaded();
    return List.unmodifiable(_recipes);
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    await _ensureLoaded();
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Recipe>> searchRecipes(String query, {String? category}) async {
    await _ensureLoaded();
    final cleanQuery = query.toLowerCase().trim();

    return _recipes.where((recipe) {
      // Dynamic search by recipe name / title
      final matchesQuery =
          cleanQuery.isEmpty ||
          recipe.title.toLowerCase().contains(cleanQuery) ||
          recipe.description.toLowerCase().contains(cleanQuery) ||
          recipe.cuisine.toLowerCase().contains(cleanQuery) ||
          recipe.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(cleanQuery),
          );

      // Category matching: 'Quick Meals', 'Healthy Bowls', 'Desserts', or 'All'
      final matchesCategory =
          category == null ||
          category.isEmpty ||
          category == 'All' ||
          category == 'All Recipes' ||
          recipe.category.toLowerCase() == category.toLowerCase() ||
          recipe.categories.any(
            (c) => c.toLowerCase() == category.toLowerCase(),
          );

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Future<void> toggleFavorite(String recipeId) async {
    await _ensureLoaded();
    final index = _recipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      final current = _recipes[index];
      _recipes[index] = current.copyWith(isFavorite: !current.isFavorite);

      // Broadcast changes immediately to active listeners
      notifyListeners();

      // Persist to local storage in background
      final favIds = _recipes
          .where((r) => r.isFavorite)
          .map((r) => r.id)
          .toList();
      _localStorageService.saveFavoriteRecipeIds(favIds);
    }
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    await _ensureLoaded();
    return _recipes.where((r) => r.isFavorite).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    await _ensureLoaded();
    return const [
      'All Recipes',
      'Quick Meals',
      'Healthy Bowls',
      'Desserts',
      'Traditional Indian Dishes',
    ];
  }

  @override
  Future<void> clearAllFavorites() async {
    await _ensureLoaded();
    _recipes = _recipes.map((r) => r.copyWith(isFavorite: false)).toList();
    notifyListeners();
    await _localStorageService.clearFavorites();
  }
}
