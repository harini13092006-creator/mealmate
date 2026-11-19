import 'package:flutter/material.dart';

import '../../../domain/models/meal_plan.dart';
import '../../../domain/models/recipe.dart';
import '../../../domain/repositories/meal_plan_repository.dart';
import '../../../domain/repositories/recipe_repository.dart';

class HomeViewModel extends ChangeNotifier {
  final RecipeRepository recipeRepository;
  final MealPlanRepository mealPlanRepository;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<Recipe> _allRecipes = [];
  List<Recipe> _featuredRecipes = [];
  List<Recipe> get featuredRecipes => _featuredRecipes;

  List<Recipe> _displayedRecipes = [];
  List<Recipe> get displayedRecipes => _displayedRecipes;

  List<PlannedMeal> _todayMeals = [];
  List<PlannedMeal> get todayMeals => _todayMeals;

  final List<String> _categories = const [
    'All',
    'Quick Meals',
    'Healthy Bowls',
    'Desserts',
    'Traditional Indian Dishes',
  ];
  List<String> get categories => _categories;

  String _selectedCategory = 'All';
  String get selectedCategory => _selectedCategory;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _disposed = false;

  HomeViewModel({
    required this.recipeRepository,
    required this.mealPlanRepository,
  }) {
    if (recipeRepository is Listenable) {
      (recipeRepository as Listenable).addListener(_onRecipesChanged);
    }
    loadHomeData();
  }

  void _onRecipesChanged() async {
    final recipes = await recipeRepository.getRecipes();
    if (_disposed) return;
    _allRecipes = recipes;
    _featuredRecipes = _allRecipes.take(4).toList();
    _filterDisplayedRecipes();
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    if (recipeRepository is Listenable) {
      (recipeRepository as Listenable).removeListener(_onRecipesChanged);
    }
    super.dispose();
  }

  Future<void> loadHomeData() async {
    if (_disposed) return;
    _isLoading = true;
    notifyListeners();

    try {
      final recipes = await recipeRepository.getRecipes();
      final meals = await mealPlanRepository.getMealsForDate(DateTime.now());
      if (_disposed) return;
      _allRecipes = recipes;
      _featuredRecipes = _allRecipes.take(4).toList();
      _todayMeals = meals;
      _filterDisplayedRecipes();
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
    _filterDisplayedRecipes();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filterDisplayedRecipes();
    notifyListeners();
  }

  void _filterDisplayedRecipes() {
    final cleanQuery = _searchQuery.toLowerCase().trim();

    _displayedRecipes = _allRecipes.where((recipe) {
      // Dynamic search by recipe name
      final matchesName =
          cleanQuery.isEmpty ||
          recipe.title.toLowerCase().contains(cleanQuery) ||
          recipe.name.toLowerCase().contains(cleanQuery) ||
          recipe.cuisine.toLowerCase().contains(cleanQuery) ||
          recipe.category.toLowerCase().contains(cleanQuery) ||
          recipe.ingredients.any(
            (ingredient) => ingredient.toLowerCase().contains(cleanQuery),
          );

      // Category matching
      final matchesCategory =
          _selectedCategory == 'All' ||
          recipe.category.toLowerCase() == _selectedCategory.toLowerCase() ||
          recipe.categories.any(
            (c) => c.toLowerCase() == _selectedCategory.toLowerCase(),
          );

      return matchesName && matchesCategory;
    }).toList();
  }

  Future<void> toggleFavorite(String recipeId) async {
    await recipeRepository.toggleFavorite(recipeId);
    _allRecipes = await recipeRepository.getRecipes();
    _featuredRecipes = _allRecipes.take(4).toList();
    _filterDisplayedRecipes();
    notifyListeners();
  }

  Future<void> toggleMealCompleted(String mealId) async {
    await mealPlanRepository.toggleMealCompleted(mealId);
    _todayMeals = await mealPlanRepository.getMealsForDate(DateTime.now());
    notifyListeners();
  }
}
