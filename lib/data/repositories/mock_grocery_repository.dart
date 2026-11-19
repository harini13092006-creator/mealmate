import 'package:uuid/uuid.dart';
import '../../domain/models/grocery_item.dart';
import '../../domain/repositories/grocery_repository.dart';

class MockGroceryRepository implements GroceryRepository {
  final List<GroceryItem> _items = [
    const GroceryItem(
      id: 'groc_1',
      name: 'Organic Quinoa',
      category: 'Grains & Pasta',
      quantity: '1 bag (500g)',
      isChecked: true,
      recipeOrigin: 'Mediterranean Quinoa Salad Bowl',
    ),
    const GroceryItem(
      id: 'groc_2',
      name: 'Greek Feta Cheese',
      category: 'Dairy & Eggs',
      quantity: '200g block',
      isChecked: false,
      recipeOrigin: 'Mediterranean Quinoa Salad Bowl',
    ),
    const GroceryItem(
      id: 'groc_3',
      name: 'Boneless Chicken Breasts',
      category: 'Meat & Seafood',
      quantity: '2 lbs',
      isChecked: false,
      recipeOrigin: 'Creamy Garlic Tuscan Chicken',
    ),
    const GroceryItem(
      id: 'groc_4',
      name: 'Fresh Baby Spinach',
      category: 'Produce',
      quantity: '1 box (16 oz)',
      isChecked: false,
      recipeOrigin: 'Creamy Garlic Tuscan Chicken',
    ),
    const GroceryItem(
      id: 'groc_5',
      name: 'Sun-dried Tomatoes in Oil',
      category: 'Pantry',
      quantity: '1 jar',
      isChecked: true,
      recipeOrigin: 'Creamy Garlic Tuscan Chicken',
    ),
    const GroceryItem(
      id: 'groc_6',
      name: 'Fresh Blueberries',
      category: 'Produce',
      quantity: '1 pint',
      isChecked: false,
      recipeOrigin: 'Berry Antioxidant Smoothie Bowl',
    ),
    const GroceryItem(
      id: 'groc_7',
      name: 'Chia Seeds',
      category: 'Pantry',
      quantity: '1 pouch',
      isChecked: true,
      recipeOrigin: 'Berry Antioxidant Smoothie Bowl',
    ),
  ];

  final _uuid = const Uuid();

  @override
  Future<List<GroceryItem>> getItems() async {
    return List.unmodifiable(_items);
  }

  @override
  Future<void> addItem(GroceryItem item) async {
    _items.add(item);
  }

  @override
  Future<void> toggleItemChecked(String id) async {
    final index = _items.indexWhere((i) => i.id == id);
    if (index != -1) {
      final current = _items[index];
      _items[index] = current.copyWith(isChecked: !current.isChecked);
    }
  }

  @override
  Future<void> removeItem(String id) async {
    _items.removeWhere((i) => i.id == id);
  }

  @override
  Future<void> clearCheckedItems() async {
    _items.removeWhere((i) => i.isChecked);
  }

  @override
  Future<void> addIngredientsFromRecipe(String recipeTitle, List<String> ingredients) async {
    for (final ingredient in ingredients) {
      _items.add(
        GroceryItem(
          id: _uuid.v4(),
          name: ingredient,
          category: 'Recipe Ingredients',
          quantity: '1 portion',
          isChecked: false,
          recipeOrigin: recipeTitle,
        ),
      );
    }
  }
}
