import '../../domain/models/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';

class MockRecipeRepository implements RecipeRepository {
  final List<Recipe> _recipes = [
    const Recipe(
      id: 'rec_1',
      title: 'Mediterranean Quinoa Salad Bowl',
      description: 'A vibrant, protein-packed bowl tossed with cucumbers, cherry tomatoes, kalamata olives, and feta cheese in a lemon oregano vinaigrette.',
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80',
      prepTimeMinutes: 15,
      cookTimeMinutes: 15,
      servings: 2,
      categories: ['Salads', 'Vegetarian', 'Quick & Easy', 'Mediterranean'],
      ingredients: [
        '1 cup cooked Quinoa',
        '1 cup diced Cucumbers',
        '1/2 cup Cherry Tomatoes halved',
        '1/4 cup Kalamata Olives pitted',
        '1/4 cup crumbled Feta Cheese',
        '2 tbsp Extra Virgin Olive Oil',
        '1 tbsp fresh Lemon Juice',
        '1/2 tsp dried Oregano',
        'Salt and cracked black pepper to taste',
      ],
      instructions: [
        'Cook quinoa according to package instructions and let it cool slightly.',
        'In a large mixing bowl, whisk olive oil, lemon juice, dried oregano, salt, and pepper.',
        'Add diced cucumber, halved cherry tomatoes, and kalamata olives to the dressing.',
        'Gently fold in the cooked quinoa.',
        'Top with crumbled feta cheese and serve chilled or at room temperature.',
      ],
      nutrition: NutritionInfo(
        calories: 380,
        proteinGrams: 12.0,
        carbsGrams: 42.0,
        fatGrams: 18.0,
      ),
      isFavorite: true,
      rating: 4.9,
    ),
    const Recipe(
      id: 'rec_2',
      title: 'Creamy Garlic Tuscan Chicken',
      description: 'Pan-seared chicken breasts simmered in a rich garlic cream sauce with sun-dried tomatoes and fresh baby spinach.',
      imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80',
      prepTimeMinutes: 10,
      cookTimeMinutes: 20,
      servings: 4,
      categories: ['High Protein', 'Keto', 'Dinner', 'Italian'],
      ingredients: [
        '2 large boneless, skinless Chicken Breasts halved horizontally',
        '2 tbsp Olive Oil',
        '1 tbsp Italian Herb Seasoning',
        '3 cloves Garlic minced',
        '1/2 cup heavy Cream',
        '1/2 cup Chicken Broth',
        '1/3 cup chopped Sun-dried Tomatoes',
        '2 cups fresh Baby Spinach',
        '1/4 cup grated Parmesan Cheese',
      ],
      instructions: [
        'Season chicken cutlets with salt, pepper, and Italian seasoning.',
        'Heat 1 tbsp olive oil in a skillet over medium-high heat. Sear chicken for 5 minutes per side until golden; remove and set aside.',
        'In the same skillet, add remaining oil and sauté garlic until fragrant (30 seconds).',
        'Pour in chicken broth and heavy cream, bringing to a gentle simmer.',
        'Stir in sun-dried tomatoes, parmesan, and baby spinach until spinach is wilted.',
        'Return chicken to the skillet, spoon sauce over, and simmer for another 3 minutes.',
      ],
      nutrition: NutritionInfo(
        calories: 520,
        proteinGrams: 46.0,
        carbsGrams: 8.0,
        fatGrams: 34.0,
      ),
      isFavorite: true,
      rating: 4.95,
    ),
    const Recipe(
      id: 'rec_3',
      title: 'Berry Antioxidant Smoothie Bowl',
      description: 'Thick, creamy smoothie bowl topped with sliced banana, chia seeds, fresh blueberries, and toasted coconut flakes.',
      imageUrl: 'https://images.unsplash.com/photo-1590301157890-4810ed352733?auto=format&fit=crop&w=800&q=80',
      prepTimeMinutes: 10,
      cookTimeMinutes: 0,
      servings: 1,
      categories: ['Breakfast', 'Vegan', 'Smoothies', 'Quick & Easy'],
      ingredients: [
        '1 cup frozen mixed Berries',
        '1 ripe Banana frozen',
        '1/2 cup Greek or Coconut Yogurt',
        '1/4 cup Almond Milk',
        '1 tbsp Chia Seeds',
        '1 tbsp Granola or Coconut Flakes',
      ],
      instructions: [
        'Add frozen berries, banana, yogurt, and almond milk to a high-speed blender.',
        'Blend on high until smooth and thick, adding extra almond milk only if necessary.',
        'Pour into a serving bowl.',
        'Arrange chia seeds, fresh blueberries, banana slices, and coconut flakes on top.',
      ],
      nutrition: NutritionInfo(
        calories: 310,
        proteinGrams: 14.0,
        carbsGrams: 52.0,
        fatGrams: 6.0,
      ),
      isFavorite: false,
      rating: 4.7,
    ),
    const Recipe(
      id: 'rec_4',
      title: 'Honey Ginger Salmon with Asparagus',
      description: 'Oven-roasted wild salmon fillets coated in a savory honey-soy glaze alongside tender roasted asparagus spears.',
      imageUrl: 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=800&q=80',
      prepTimeMinutes: 10,
      cookTimeMinutes: 15,
      servings: 2,
      categories: ['High Protein', 'Gluten-Free', 'Dinner', 'Seafood'],
      ingredients: [
        '2 Salmon fillets (6 oz each)',
        '1 bunch fresh Asparagus trimmed',
        '2 tbsp Honey',
        '2 tbsp Low-Sodium Tamari or Soy Sauce',
        '1 tbsp grated fresh Ginger',
        '1 clove Garlic minced',
        '1 tsp Sesame Oil',
        '1 tsp Sesame Seeds for garnish',
      ],
      instructions: [
        'Preheat oven to 400°F (200°C) and line a baking sheet with parchment.',
        'In a small bowl, whisk together honey, soy sauce, minced ginger, garlic, and sesame oil.',
        'Place salmon fillets and asparagus on the baking sheet.',
        'Brush salmon generously with the honey-ginger glaze and drizzle olive oil over asparagus.',
        'Bake for 12-15 minutes until salmon is flaky and cooked through.',
        'Garnish with toasted sesame seeds and serve immediately.',
      ],
      nutrition: NutritionInfo(
        calories: 440,
        proteinGrams: 38.0,
        carbsGrams: 22.0,
        fatGrams: 20.0,
      ),
      isFavorite: true,
      rating: 4.88,
    ),
    const Recipe(
      id: 'rec_5',
      title: 'Avocado Toast with Poached Egg',
      description: 'Toasted sourdough bread topped with mashed seasoned avocado, a delicate runny poached egg, and crushed red pepper flakes.',
      imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80',
      prepTimeMinutes: 8,
      cookTimeMinutes: 5,
      servings: 1,
      categories: ['Breakfast', 'Vegetarian', 'Quick & Easy'],
      ingredients: [
        '1 slice Artisan Sourdough Bread',
        '1/2 ripe Avocado',
        '1 large pasture-raised Egg',
        '1 tsp Lemon juice',
        '1/4 tsp Red Pepper Flakes',
        'Sea salt and freshly cracked black pepper',
      ],
      instructions: [
        'Toast the sourdough slice until crisp and golden.',
        'In a bowl, mash avocado with lemon juice, sea salt, and black pepper.',
        'Bring a small pot of water with 1 tsp vinegar to a gentle simmer. Swirl water and gently slide in the egg; poach for 3 minutes.',
        'Spread mashed avocado over toast and carefully top with the poached egg.',
        'Sprinkle with red pepper flakes and serve warm.',
      ],
      nutrition: NutritionInfo(
        calories: 290,
        proteinGrams: 11.0,
        carbsGrams: 24.0,
        fatGrams: 17.0,
      ),
      isFavorite: false,
      rating: 4.85,
    ),
  ];

  @override
  Future<List<Recipe>> getRecipes() async {
    return List.unmodifiable(_recipes);
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Recipe>> searchRecipes(String query, {String? category}) async {
    final cleanQuery = query.toLowerCase().trim();
    return _recipes.where((recipe) {
      final matchesQuery = cleanQuery.isEmpty ||
          recipe.title.toLowerCase().contains(cleanQuery) ||
          recipe.description.toLowerCase().contains(cleanQuery) ||
          recipe.ingredients.any((i) => i.toLowerCase().contains(cleanQuery));

      final matchesCategory = category == null ||
          category.isEmpty ||
          category == 'All' ||
          recipe.categories.contains(category);

      return matchesQuery && matchesCategory;
    }).toList();
  }

  @override
  Future<void> toggleFavorite(String recipeId) async {
    final index = _recipes.indexWhere((r) => r.id == recipeId);
    if (index != -1) {
      final current = _recipes[index];
      _recipes[index] = current.copyWith(isFavorite: !current.isFavorite);
    }
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    return _recipes.where((r) => r.isFavorite).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    final set = <String>{'All'};
    for (final r in _recipes) {
      set.addAll(r.categories);
    }
    return set.toList();
  }

  @override
  Future<void> clearAllFavorites() async {
    for (int i = 0; i < _recipes.length; i++) {
      _recipes[i] = _recipes[i].copyWith(isFavorite: false);
    }
  }
}
