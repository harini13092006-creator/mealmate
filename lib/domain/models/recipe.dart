class NutritionInfo {
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatGrams;

  const NutritionInfo({
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatGrams,
  });

  Map<String, dynamic> toJson() => {
    'calories': calories,
    'proteinGrams': proteinGrams,
    'carbsGrams': carbsGrams,
    'fatGrams': fatGrams,
  };

  factory NutritionInfo.fromJson(Map<String, dynamic> json) => NutritionInfo(
    calories: (json['calories'] as num).toInt(),
    proteinGrams: (json['proteinGrams'] as num).toDouble(),
    carbsGrams: (json['carbsGrams'] as num).toDouble(),
    fatGrams: (json['fatGrams'] as num).toDouble(),
  );
}

class Recipe {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String cuisine;
  final String foodType;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final String difficultyLevel;
  final int servings;
  final List<String> categories;
  final List<String> ingredients;
  final List<String> instructions;
  final NutritionInfo nutrition;
  final bool isFavorite;
  final double rating;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.cuisine = 'Indian',
    this.foodType = 'Vegetarian',
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    this.difficultyLevel = 'Easy',
    required this.servings,
    required this.categories,
    required this.ingredients,
    required this.instructions,
    required this.nutrition,
    this.isFavorite = false,
    this.rating = 4.8,
  });

  String get name => title;
  String get category => categories.isNotEmpty ? categories.first : 'General';
  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? cuisine,
    String? foodType,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    String? difficultyLevel,
    int? servings,
    List<String>? categories,
    List<String>? ingredients,
    List<String>? instructions,
    NutritionInfo? nutrition,
    bool? isFavorite,
    double? rating,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      cuisine: cuisine ?? this.cuisine,
      foodType: foodType ?? this.foodType,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      servings: servings ?? this.servings,
      categories: categories ?? this.categories,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      nutrition: nutrition ?? this.nutrition,
      isFavorite: isFavorite ?? this.isFavorite,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'name': title,
    'category': category,
    'description': description,
    'imageUrl': imageUrl,
    'image': imageUrl,
    'cuisine': cuisine,
    'foodType': foodType,
    'prepTimeMinutes': prepTimeMinutes,
    'cookTimeMinutes': cookTimeMinutes,
    'difficultyLevel': difficultyLevel,
    'servings': servings,
    'categories': categories,
    'ingredients': ingredients,
    'instructions': instructions,
    'nutrition': nutrition.toJson(),
    'isFavorite': isFavorite,
    'rating': rating,
  };

  factory Recipe.fromJson(Map<String, dynamic> json) {
    final title = (json['title'] ?? json['name'] ?? '') as String;
    List<String> categoriesList = [];
    if (json['categories'] != null) {
      categoriesList = List<String>.from(json['categories'] as List);
    } else if (json['category'] != null) {
      categoriesList = [json['category'] as String];
    }

    return Recipe(
      id: json['id'] as String,
      title: title,
      description: (json['description'] ?? '') as String,
      imageUrl: (json['image'] ?? json['imageUrl'] ?? '') as String,
      cuisine: (json['cuisine'] ?? 'Indian') as String,
      foodType: (json['foodType'] ?? 'Vegetarian') as String,
      prepTimeMinutes: (json['prepTimeMinutes'] as num?)?.toInt() ?? 0,
      cookTimeMinutes: (json['cookTimeMinutes'] as num?)?.toInt() ?? 0,
      difficultyLevel: (json['difficultyLevel'] as String?) ?? 'Easy',
      servings: (json['servings'] as num?)?.toInt() ?? 2,
      categories: categoriesList,
      ingredients: List<String>.from(json['ingredients'] as List? ?? []),
      instructions: List<String>.from(json['instructions'] as List? ?? []),
      nutrition: NutritionInfo.fromJson(
        json['nutrition'] as Map<String, dynamic>,
      ),
      isFavorite: json['isFavorite'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
    );
  }
}
