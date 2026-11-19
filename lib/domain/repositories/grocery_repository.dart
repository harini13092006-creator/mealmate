import '../models/grocery_item.dart';

abstract class GroceryRepository {
  Future<List<GroceryItem>> getItems();
  Future<void> addItem(GroceryItem item);
  Future<void> toggleItemChecked(String id);
  Future<void> removeItem(String id);
  Future<void> clearCheckedItems();
  Future<void> addIngredientsFromRecipe(String recipeTitle, List<String> ingredients);
}
