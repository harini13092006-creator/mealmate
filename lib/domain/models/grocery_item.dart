class GroceryItem {
  final String id;
  final String name;
  final String category;
  final String quantity;
  final bool isChecked;
  final String? recipeOrigin;

  const GroceryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    this.isChecked = false,
    this.recipeOrigin,
  });

  GroceryItem copyWith({
    String? id,
    String? name,
    String? category,
    String? quantity,
    bool? isChecked,
    String? recipeOrigin,
  }) {
    return GroceryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      isChecked: isChecked ?? this.isChecked,
      recipeOrigin: recipeOrigin ?? this.recipeOrigin,
    );
  }
}
