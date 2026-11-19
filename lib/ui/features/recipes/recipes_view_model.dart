import 'package:flutter/material.dart';

import '../../../domain/models/recipe.dart';
import '../../../domain/repositories/recipe_repository.dart';

class RecipesViewModel extends ChangeNotifier {
  final RecipeRepository recipeRepository;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Recipe> _recipes = [];
  List<Recipe> get recipes => _recipes;

  List<String> _categories = ['All'];
  List<String> get categories => _categories;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _showFavoritesOnly = false;
  bool get showFavoritesOnly => _showFavoritesOnly;
  String _selectedCuisine = 'All cuisines';
  String get selectedCuisine => _selectedCuisine;
  String _selectedFoodType = 'All types';
  String get selectedFoodType => _selectedFoodType;
  String _sortBy = 'Recently added';
  String get sortBy => _sortBy;

  bool _disposed = false;

  RecipesViewModel({required this.recipeRepository}) {
    if (recipeRepository is Listenable) {
      (recipeRepository as Listenable).addListener(_onRecipesChanged);
    }
    loadRecipes();
  }

  void _onRecipesChanged() {
    _filterRecipes();
  }

  @override
  void dispose() {
    _disposed = true;
    if (recipeRepository is Listenable) {
      (recipeRepository as Listenable).removeListener(_onRecipesChanged);
    }
    super.dispose();
  }

  Future<void> loadRecipes() async {
    if (_disposed) return;
    _isLoading = true;
    notifyListeners();

    try {
      final cats = await recipeRepository.getCategories();
      if (_disposed) return;
      _categories = cats;
      await _filterRecipes();
    } finally {
      if (!_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void setCategory(String category) {
    if (_selectedCategory == category) return;
    _selectedCategory = category;
    _filterRecipes();
  }

  void search(String query) {
    _searchQuery = query;
    _filterRecipes();
  }

  void toggleFavoritesFilter() {
    _showFavoritesOnly = !_showFavoritesOnly;
    _filterRecipes();
  }

  void setCuisine(String value) {
    _selectedCuisine = value;
    _filterRecipes();
  }

  void setFoodType(String value) {
    _selectedFoodType = value;
    _filterRecipes();
  }

  void setSortBy(String value) {
    _sortBy = value;
    _filterRecipes();
  }

  Future<void> _filterRecipes() async {
    final list = await recipeRepository.searchRecipes(
      _searchQuery,
      category: _selectedCategory,
    );
    var filtered = list
        .where(
          (r) =>
              (_selectedCuisine == 'All cuisines' ||
                  r.cuisine == _selectedCuisine) &&
              (_selectedFoodType == 'All types' ||
                  r.foodType == _selectedFoodType) &&
              (!_showFavoritesOnly || r.isFavorite),
        )
        .toList();
    if (_sortBy == 'Recipe name') {
      filtered.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
    } else if (_sortBy == 'Preparation time') {
      filtered.sort((a, b) => a.prepTimeMinutes.compareTo(b.prepTimeMinutes));
    } else {
      filtered.sort((a, b) {
        final aNew = a.id.startsWith('ind_');
        final bNew = b.id.startsWith('ind_');
        if (aNew != bNew) return aNew ? -1 : 1;
        return b.id.compareTo(a.id);
      });
    }
    _recipes = filtered;
    notifyListeners();
  }

  Future<void> toggleFavorite(String recipeId) async {
    await recipeRepository.toggleFavorite(recipeId);
    await _filterRecipes();
  }
}
