import 'package:flutter/material.dart';
import '../../../domain/models/recipe.dart';
import '../../../domain/repositories/recipe_repository.dart';

class FavoritesViewModel extends ChangeNotifier {
  final RecipeRepository recipeRepository;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Recipe> _favoriteRecipes = [];
  List<Recipe> get favoriteRecipes => _favoriteRecipes;

  bool _disposed = false;

  FavoritesViewModel({required this.recipeRepository}) {
    if (recipeRepository is Listenable) {
      (recipeRepository as Listenable).addListener(_onRepoChanged);
    }
    loadFavorites();
  }

  void _onRepoChanged() {
    loadFavorites(silent: true);
  }

  Future<void> loadFavorites({bool silent = false}) async {
    if (_disposed) return;
    if (!silent) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final favs = await recipeRepository.getFavoriteRecipes();
      if (_disposed) return;
      _favoriteRecipes = favs;
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> toggleFavorite(String recipeId) async {
    await recipeRepository.toggleFavorite(recipeId);
    if (recipeRepository is! Listenable) {
      await loadFavorites(silent: true);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    if (recipeRepository is Listenable) {
      (recipeRepository as Listenable).removeListener(_onRepoChanged);
    }
    super.dispose();
  }
}
