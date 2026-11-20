# 🍽️ Mealmate – Recipe & Weekly Meal Planner

Mealmate is an offline-first Flutter application designed to help users explore Indian recipes, manage favorite dishes, track cooking ingredients, and organize weekly meal plans.

The application uses a bundled JSON recipe catalog for offline recipe browsing and SharedPreferences for locally storing user preferences and activities. No internet connection is required for the core application features.

## 1. Project Overview

Mealmate provides the following features:

- Browse 120 Indian recipes.
- Explore recipes by category.
- Search recipes by name and keywords.
- Filter recipes by cuisine and food type.
- Sort recipes by name and preparation time.
- View detailed ingredients and cooking instructions.
- Mark ingredients as completed using an interactive checklist.
- Save and remove favorite recipes.
- Create and manage weekly meal plans.
- Store user data locally using SharedPreferences.
- Access the recipe catalog without an internet connection.

## 2. Recipe Categories

The recipe catalog contains 120 Indian dishes organized into four main categories.

| Category | Description | Example Recipes |
|---|---|---|
| Quick Meals | Simple and quick-to-prepare Indian dishes | Idli, Dosa, Upma |
| Healthy Bowls | Nutritious meals with balanced ingredients | Millet Bowl, Sprout Salad |
| Desserts | Traditional and modern Indian sweets | Gulab Jamun, Payasam |
| Traditional Indian Dishes | Regional Indian food and traditional preparations | Biryani, Pongal, Paneer Curry |

Each recipe belongs to a category and includes additional classification information such as cuisine and vegetarian or non-vegetarian type.

### 2.1 Category Schema

The recipe category is represented using a structured string field in the JSON recipe object.

Example:

```json
{
  "id": "ind_001",
  "name": "Masala Dosa",
  "category": "Quick Meals",
  "cuisine": "South Indian",
  "foodType": "Vegetarian"
}
```

**Category fields:**

| Field | Data Type | Description |
|---|---|---|
| id | String | Unique recipe identifier |
| name | String | Recipe name |
| category | String | Main recipe category |
| cuisine | String | Regional or cultural cuisine |
| foodType | String | Vegetarian or non-vegetarian classification |

The category field is used to organize and filter recipes within the application.

## 3. Recipe JSON Data Structure

All recipe information is stored in the bundled file:

`assets/recipes.json`

The JSON file contains 120 Indian recipes with their ingredients, preparation details, cooking instructions, images, and approximate nutritional information.

### 3.1 Recipe Schema

Each recipe contains the following information:

| Field | Data Type | Description |
|---|---|---|
| id | String | Stable unique recipe ID |
| name | String | Name of the dish |
| category | String | Recipe category |
| cuisine | String | Cuisine classification |
| description | String | Short recipe description |
| foodType | String | Vegetarian or non-vegetarian |
| servings | Number | Number of servings |
| preparationTime | Number | Preparation time in minutes |
| cookingTime | Number | Cooking time in minutes |
| ingredients | Array | List of measured ingredients |
| instructions | Array | Ordered cooking steps |
| image | String | Local recipe image asset path |
| nutrition | Object | Approximate nutritional values per serving |

The exact field names and data types must remain consistent with the existing recipe model and JSON catalog.

### 3.2 Ingredients Structure

Each recipe contains an ingredients array.

Every ingredient includes:

- Unique ingredient identifier.
- Ingredient name.
- Measured quantity.
- Measurement unit.

Example:

```json
{
  "id": "ing_001",
  "name": "Rice",
  "quantity": 2,
  "unit": "cups"
}
```

The ingredient checklist allows users to mark ingredients as completed while preparing a recipe.

### 3.3 Cooking Instructions Structure

Cooking instructions are stored as an ordered array of steps.

Example:

```json
[
  "Wash and soak the rice.",
  "Prepare the required spices.",
  "Cook the ingredients according to the recipe.",
  "Garnish and serve hot."
]
```

The application displays these instructions in sequence on the recipe details screen.

### 3.4 Nutrition Structure

Each recipe includes approximate nutritional information per serving.

Typical values include:

- Calories
- Protein
- Carbohydrates
- Fat

**Note:** Nutritional values are estimates and are not based on laboratory analysis.

## 4. Local Storage Structure

Mealmate follows an offline-first architecture.

Recipe information is loaded from the bundled JSON catalog, while user-specific data is stored locally using Flutter SharedPreferences.

No external database or backend server is required for the core application functionality.

### 4.1 Storage Overview

| Data | Storage Method | Purpose |
|---|---|---|
| Recipe catalog | Local JSON asset | Stores all recipe information |
| Favorite recipes | SharedPreferences | Saves favorite recipe IDs |
| Checked ingredients | SharedPreferences | Stores ingredient checklist states |
| Weekly meal assignments | SharedPreferences | Stores assigned recipes for each day and meal |
| User preferences | SharedPreferences | Stores supported application preferences |

### 4.2 Favorite Recipes Storage

Favorite recipes are stored locally using their stable recipe IDs.

Example:

```text
favoriteRecipes = [
  "ind_001",
  "ind_015",
  "ind_032"
]
```

When the user adds or removes a favorite, the updated list is saved to SharedPreferences.

This ensures that favorite recipes remain available after closing and reopening the application.

### 4.3 Ingredient Checklist Storage

Ingredient checklist states are stored using recipe and ingredient identifiers.

Conceptual structure:

```json
{
  "ind_001": {
    "ing_001": true,
    "ing_002": false,
    "ing_003": true
  }
}
```

Here:

- `true` indicates that an ingredient has been checked.
- `false` indicates that an ingredient has not been checked.

Using stable identifiers helps preserve checklist states for individual recipes.

### 4.4 Weekly Meal Planner Storage

Weekly meal assignments are stored locally using SharedPreferences.

The planner supports:

- Seven days of the week.
- Breakfast.
- Lunch.
- Dinner.

Conceptual data structure:

```json
{
  "Monday": {
    "Breakfast": "ind_001",
    "Lunch": "ind_015",
    "Dinner": "ind_032"
  },
  "Tuesday": {
    "Breakfast": "ind_008",
    "Lunch": "ind_020",
    "Dinner": "ind_045"
  }
}
```

Each assignment references a recipe using its stable ID.

The application retrieves the corresponding recipe details from the bundled JSON catalog.

### 4.5 Local Storage Benefits

- Works without an internet connection.
- Retains favorites between application sessions.
- Preserves ingredient checklist states.
- Saves weekly meal assignments.
- Reduces dependency on external services.
- Provides fast access to locally stored information.

## 5. Project Folder Structure

The main project structure is organized as follows:

```text
mealmate/
│
├── assets/
│   ├── recipes.json
│   │
│   └── images/
│       └── recipes/
│
├── lib/
│   ├── main.dart
│   │
│   ├── models/
│   │   └── recipe.dart
│   │
│   ├── providers/
│   │   ├── recipe_provider.dart
│   │   ├── favorites_provider.dart
│   │   └── meal_plan_provider.dart
│   │
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── recipe_detail_screen.dart
│   │   ├── favorites_screen.dart
│   │   ├── meal_planner_screen.dart
│   │   └── settings_screen.dart
│   │
│   ├── services/
│   │   └── storage_service.dart
│   │
│   ├── widgets/
│   │   ├── recipe_card.dart
│   │   └── category_selector.dart
│   │
│   └── theme/
│       └── app_theme.dart
│
├── scripts/
│   ├── validate_recipes.py
│   └── generate_indian_recipes.py
│
├── test/
│
├── pubspec.yaml
├── README.md
└── MISSING_PHOTOS.txt
```

*Note: The structure above illustrates the intended organization. Actual filenames may vary according to the implemented project.*

## 6. Offline-First Architecture

The application uses a simple local data flow:

```text
          MEALMATE APPLICATION
                   |
                   v
           Recipe JSON Catalog
          (assets/recipes.json)
                   |
                   v
           Recipe Data Model
                   |
                   v
          Recipe Browsing UI
                   |
          -------------------
          |        |        |
          v        v        v
       Favorites  Checklist  Meal Planner
          |        |        |
          -------------------
                   |
                   v
            SharedPreferences
              Local Storage
```

The bundled recipe catalog provides the recipe information, while SharedPreferences maintains user-specific data.

This architecture allows the main application features to work offline.

## 7. Recipe Photograph Management

Recipe images are referenced through local asset paths in `assets/recipes.json`.

Expected image directory:

```text
assets/
└── images/
    └── recipes/
        ├── idli.jpg
        ├── dosa.jpg
        ├── masala_dosa.jpg
        └── ...
```

Each recipe should use its corresponding genuine, properly licensed photograph.

Until a suitable image is added, the application displays a **Photo unavailable** placeholder.

No unrelated or repeated photographs should be assigned to recipes.

## 8. Validation and Data Generation

The recipe catalog can be validated using:

```bash
python scripts/validate_recipes.py
```

This script checks the recipe catalog for data consistency and validation errors.

To regenerate the curated JSON catalog from its editable recipe list and instructions, run:

```bash
python scripts/generate_indian_recipes.py
```

After regenerating the catalog, run the validation script again.

## 9. Installation and Execution

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or Visual Studio Code
- Android emulator or physical Android device

### Install dependencies

```bash
flutter pub get
```

### Run the application

```bash
flutter run
```

### Analyze the project

```bash
flutter analyze
```

### Run tests

```bash
flutter test
```

## 10. Technologies Used

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Application programming language |
| JSON | Bundled recipe data storage |
| SharedPreferences | Local user data persistence |
| Material Design | Application user interface |

## 11. Conclusion

Mealmate provides an offline-first solution for discovering Indian recipes and organizing weekly meals.

Its structured recipe category schema makes recipe discovery and filtering easier, while local JSON assets and SharedPreferences provide reliable offline access to recipe information and user activities.

The application combines recipe browsing, ingredient tracking, favorites, and weekly meal planning in a single mobile application.