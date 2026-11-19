import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/models/grocery_item.dart';
import '../../../domain/repositories/grocery_repository.dart';

class GroceriesViewModel extends ChangeNotifier {
  final GroceryRepository groceryRepository;
  final _uuid = const Uuid();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  List<GroceryItem> _items = [];
  List<GroceryItem> get items => _items;

  GroceriesViewModel({required this.groceryRepository}) {
    loadGroceries();
  }

  Future<void> loadGroceries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await groceryRepository.getItems();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleItem(String id) async {
    await groceryRepository.toggleItemChecked(id);
    _items = await groceryRepository.getItems();
    notifyListeners();
  }

  Future<void> addItem({
    required String name,
    required String category,
    required String quantity,
  }) async {
    final newItem = GroceryItem(
      id: _uuid.v4(),
      name: name,
      category: category.isEmpty ? 'General' : category,
      quantity: quantity.isEmpty ? '1 item' : quantity,
    );
    await groceryRepository.addItem(newItem);
    _items = await groceryRepository.getItems();
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    await groceryRepository.removeItem(id);
    _items = await groceryRepository.getItems();
    notifyListeners();
  }

  Future<void> clearCompleted() async {
    await groceryRepository.clearCheckedItems();
    _items = await groceryRepository.getItems();
    notifyListeners();
  }

  Future<void> addRecipeIngredients(String recipeTitle, List<String> ingredients) async {
    await groceryRepository.addIngredientsFromRecipe(recipeTitle, ingredients);
    _items = await groceryRepository.getItems();
    notifyListeners();
  }
}
