import '../models/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getRecipes();
  Future<Recipe?> getRecipeById(String id);
  Future<List<Recipe>> searchRecipes(String query, {String? category});
  Future<void> toggleFavorite(String recipeId);
  Future<List<Recipe>> getFavoriteRecipes();
  Future<List<String>> getCategories();
  Future<void> clearAllFavorites();
}
