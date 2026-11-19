# Mealmate

Mealmate is an offline-first Flutter recipe browser and weekly meal planner. Its bundled recipe catalog lives in `assets/recipes.json`; favorite recipes, checked ingredients, and meal assignments continue to use local SharedPreferences storage.

## Indian recipe catalog

The bundled JSON contains 120 Indian dishes across Quick Meals, Healthy Bowls, Desserts, and Traditional Indian Dishes. Every entry includes a stable ID, cuisine, vegetarian classification, serving quantity, prep/cook times, measured ingredients, ordered cooking steps, an image asset path, and approximate per-serving nutrition. Nutrition figures are estimates, not laboratory analysis. Cuisine and food type filters, broad search, and name/preparation-time sorting are available in recipe discovery.

Validate the catalog with `python scripts/validate_recipes.py`. To regenerate the curated JSON from its editable recipe list and instructions, run `python scripts/generate_indian_recipes.py`.

## Recipe photographs

No genuine, dish-matched photographs were present in the project or available as local assets. Each Indian recipe points to a unique expected JPG under `assets/images/recipes/`; the UI shows an explicit “Photo unavailable” placeholder until that licensed dish photo is added. The exact 120 missing filenames are listed in [MISSING_PHOTOS.txt](assets/images/recipes/MISSING_PHOTOS.txt) and can be found in the JSON image fields. No repeated or unrelated images are assigned.

## Run

Use `flutter pub get`, then `flutter run` on a configured device. Run `flutter analyze` and `flutter test` to check the Flutter project.
