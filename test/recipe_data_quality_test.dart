import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'recipe catalog has complete, distinct, ordered instruction data',
    () async {
      final source = await rootBundle.loadString('assets/recipes.json');
      final recipes = (jsonDecode(source) as List).cast<Map<String, dynamic>>();
      final ids = <String>{};
      final sequences = <String>{};

      for (final recipe in recipes) {
        final name = recipe['name'] as String;
        expect(
          ids.add(recipe['id'] as String),
          isTrue,
          reason: '$name has a duplicate ID',
        );
        expect(
          recipe['category'],
          isNotNull,
          reason: '$name lost its category',
        );

        final ingredients = (recipe['ingredients'] as List).cast<String>();
        final steps = (recipe['instructions'] as List).cast<String>();
        expect(ingredients, isNotEmpty, reason: '$name has no ingredients');
        expect(ingredients.every((item) => item.trim().isNotEmpty), isTrue);
        expect(
          steps.length,
          inInclusiveRange(6, 12),
          reason: '$name needs 6–12 steps',
        );
        expect(
          steps.every((step) => step.trim().split(RegExp(r'\s+')).length >= 3),
          isTrue,
          reason: '$name has an empty or trivial step',
        );
        expect(
          steps.toSet().length,
          steps.length,
          reason: '$name repeats a step',
        );
        expect(
          sequences.add(steps.join('|').toLowerCase()),
          isTrue,
          reason: '$name duplicates another recipe method',
        );

        final prep = recipe['prepTimeMinutes'] as int;
        final cook = recipe['cookTimeMinutes'] as int;
        expect(prep, greaterThan(0), reason: '$name needs preparation time');
        expect(
          cook,
          greaterThanOrEqualTo(0),
          reason: '$name has invalid cooking time',
        );
        expect(
          recipe['totalTimeMinutes'],
          prep + cook,
          reason: '$name total time must equal preparation plus cooking',
        );

        final lowerIngredients = ingredients.join(' ').toLowerCase();
        final lowerName = name.toLowerCase();
        if (lowerName.contains('chicken')) {
          expect(
            lowerIngredients,
            contains('chicken'),
            reason: '$name omits chicken',
          );
        }
        if (lowerName.contains('mutton') ||
            lowerName.contains('kosha mangsho')) {
          expect(
            lowerIngredients,
            contains('mutton'),
            reason: '$name omits mutton',
          );
        }
        if (lowerName.contains('prawn')) {
          expect(
            lowerIngredients,
            contains('prawn'),
            reason: '$name omits prawns',
          );
        }
        if (lowerName.contains('paneer')) {
          expect(
            lowerIngredients,
            contains('paneer'),
            reason: '$name omits paneer',
          );
        }
      }

      expect(
        recipes
            .where((recipe) => (recipe['id'] as String).startsWith('ind_'))
            .length,
        greaterThanOrEqualTo(120),
      );
    },
  );
}
