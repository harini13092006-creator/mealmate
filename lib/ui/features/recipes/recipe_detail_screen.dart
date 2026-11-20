import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/storage/local_storage_service.dart';
import '../../../domain/models/meal_plan.dart';
import '../../../domain/models/recipe.dart';
import '../../../domain/repositories/recipe_repository.dart';
import '../groceries/groceries_view_model.dart';
import '../meal_planner/meal_planner_view_model.dart';

class ParsedIngredient {
  final String quantity;
  final String name;

  const ParsedIngredient({required this.quantity, required this.name});

  factory ParsedIngredient.fromString(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return const ParsedIngredient(quantity: '', name: '');

    final regex = RegExp(
      r'^((?:\d+(?:\/\d+)?(?:\.\d+)?(?:\s*-\s*\d+(?:\/\d+)?)?)\s*(?:oz|lbs?|tbsp|tsp|cups?|cloves?|cans?|packs?|pieces?|bunch|slices?|pinch|g|ml|kg)?(?:\s*\([^)]*\))?)\s+(.*)$',
      caseSensitive: false,
    );

    final match = regex.firstMatch(trimmed);
    if (match != null && match.group(1) != null && match.group(2) != null) {
      final qty = match.group(1)!.trim();
      final name = match.group(2)!.trim();
      if (qty.isNotEmpty && name.isNotEmpty) {
        return ParsedIngredient(quantity: qty, name: name);
      }
    }

    if (trimmed.toLowerCase().startsWith('pinch of ')) {
      return ParsedIngredient(
        quantity: 'Pinch',
        name: trimmed.substring(9).trim(),
      );
    }

    if (trimmed.toLowerCase().endsWith(' to taste')) {
      return ParsedIngredient(
        quantity: 'To taste',
        name: trimmed.substring(0, trimmed.length - 9).trim(),
      );
    }

    final firstSpace = trimmed.indexOf(' ');
    if (firstSpace > 0 && RegExp(r'^\d').hasMatch(trimmed)) {
      return ParsedIngredient(
        quantity: trimmed.substring(0, firstSpace).trim(),
        name: trimmed.substring(firstSpace + 1).trim(),
      );
    }

    return ParsedIngredient(quantity: 'As needed', name: trimmed);
  }
}

class RecipeDetailScreen extends StatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({super.key, required this.recipeId});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  Recipe? _recipe;
  bool _isLoading = true;

  // Maintains interactive checklist state persisted locally
  final Set<int> _checkedIndices = {};

  LocalStorageService? _storage;

  LocalStorageService get _storageService {
    if (_storage != null) return _storage!;
    try {
      _storage = context.read<LocalStorageService>();
    } catch (_) {
      _storage = LocalStorageService();
    }
    return _storage!;
  }

  @override
  void initState() {
    super.initState();
    _loadRecipe();
  }

  Future<void> _loadRecipe() async {
    final repo = context.read<RecipeRepository>();
    final r = await repo.getRecipeById(widget.recipeId);
    final savedChecked = await _storageService.getCheckedIngredients(
      widget.recipeId,
    );
    if (mounted) {
      setState(() {
        _recipe = r;
        _checkedIndices.clear();
        _checkedIndices.addAll(savedChecked);
        _isLoading = false;
      });
    }
  }

  void _toggleIngredient(int index) {
    setState(() {
      if (_checkedIndices.contains(index)) {
        _checkedIndices.remove(index);
      } else {
        _checkedIndices.add(index);
      }
    });
    _storageService.saveCheckedIngredients(widget.recipeId, _checkedIndices);
  }

  void _resetChecklist() {
    setState(() {
      _checkedIndices.clear();
    });
    _storageService.resetCheckedIngredients(widget.recipeId);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ingredient checklist reset'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _toggleFavorite() async {
    if (_recipe == null) return;
    try {
      final repo = context.read<RecipeRepository>();
      await repo.toggleFavorite(_recipe!.id);
      final updated = await repo.getRecipeById(widget.recipeId);
      if (mounted && updated != null) {
        setState(() {
          _recipe = updated;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updated.isFavorite
                  ? 'Saved to favorites!'
                  : 'Removed from favorites',
            ),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_recipe == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Recipe not found')),
      );
    }

    final recipe = _recipe!;
    final totalIngredients = recipe.ingredients.length;
    final completedIngredients = _checkedIndices.length;
    final double checklistProgress = totalIngredients > 0
        ? (completedIngredients / totalIngredients)
        : 0.0;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: CustomScrollView(
            slivers: [
              // 1. Large Hero Header with Image & Bookmark/Favorite Action
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                stretch: true,
                backgroundColor: theme.colorScheme.surface,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black87)],
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image(
                        image: recipe.imageUrl.startsWith('assets/')
                            ? AssetImage(recipe.imageUrl)
                            : NetworkImage(recipe.imageUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: Colors.orange.shade100,
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.no_photography_outlined,
                                  size: 48,
                                  color: Colors.orange,
                                ),
                                Text(
                                  'Photo unavailable',
                                  style: TextStyle(color: Colors.brown),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black45,
                              Colors.transparent,
                              Colors.black87,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [0.0, 0.4, 1.0],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  // PART 4: Bookmark / Favorite Button
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black38,
                      child: IconButton(
                        icon: Icon(
                          recipe.isFavorite
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: recipe.isFavorite
                              ? theme.colorScheme.primary
                              : Colors.white,
                        ),
                        tooltip: recipe.isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                        onPressed: _toggleFavorite,
                      ),
                    ),
                  ),
                ],
              ),

              // Content body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories and Difficulty tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              recipe.category,
                              style: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.speed_rounded,
                                  size: 14,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  recipe.difficultyLevel,
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 18,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                recipe.rating.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 2. Recipe Name
                      Text(
                        recipe.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 3. Recipe Description
                      Text(
                        recipe.description,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.textTheme.bodyMedium?.color?.withValues(
                            alpha: 0.8,
                          ),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4, 5, 6, 7. Highlights: Prep, Cook, Total, Servings
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth < 420 ? 2 : 4;
                            final itemWidth =
                                (constraints.maxWidth - (columns - 1) * 8) /
                                columns;
                            return Wrap(
                              spacing: 8,
                              runSpacing: 12,
                              children: [
                                _HighlightItem(
                                  width: itemWidth,
                                  icon: Icons.timer_outlined,
                                  title: 'Prep Time',
                                  value: '${recipe.prepTimeMinutes}m',
                                ),
                                _HighlightItem(
                                  width: itemWidth,
                                  icon: Icons.local_fire_department_outlined,
                                  title: 'Cook Time',
                                  value: '${recipe.cookTimeMinutes}m',
                                ),
                                _HighlightItem(
                                  width: itemWidth,
                                  icon: Icons.hourglass_bottom_outlined,
                                  title: 'Total Time',
                                  value: '${recipe.totalTimeMinutes}m',
                                ),
                                _HighlightItem(
                                  width: itemWidth,
                                  icon: Icons.people_outline,
                                  title: 'Servings',
                                  value: '${recipe.servings}',
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 8. Nutritional Information Section
                      Text(
                        'Nutritional Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const spacing = 8.0;
                          final columns = constraints.maxWidth < 420 ? 2 : 4;
                          final cardWidth =
                              (constraints.maxWidth - (columns - 1) * spacing) /
                              columns;
                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: [
                              SizedBox(
                                width: cardWidth,
                                child: _NutritionCard(
                                  label: 'Calories',
                                  value: '${recipe.nutrition.calories}',
                                  unit: 'kcal',
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _NutritionCard(
                                  label: 'Protein',
                                  value: recipe.nutrition.proteinGrams
                                      .toStringAsFixed(0),
                                  unit: 'g',
                                  color: Colors.blueAccent,
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _NutritionCard(
                                  label: 'Carbs',
                                  value: recipe.nutrition.carbsGrams
                                      .toStringAsFixed(0),
                                  unit: 'g',
                                  color: Colors.orangeAccent.shade700,
                                ),
                              ),
                              SizedBox(
                                width: cardWidth,
                                child: _NutritionCard(
                                  label: 'Fat',
                                  value: recipe.nutrition.fatGrams
                                      .toStringAsFixed(0),
                                  unit: 'g',
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // PART 2: INTERACTIVE INGREDIENT CHECKLIST
                      _buildIngredientChecklistHeader(
                        context,
                        completed: completedIngredients,
                        total: totalIngredients,
                        progress: checklistProgress,
                        recipe: recipe,
                      ),
                      const SizedBox(height: 12),
                      _buildIngredientChecklist(recipe.ingredients),
                      const SizedBox(height: 32),

                      // PART 3: COOKING INSTRUCTIONS
                      Text(
                        'Cooking Instructions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Follow these sequential steps for best results:',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      _buildInstructionCards(recipe.instructions),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Bottom Bar
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: const Icon(Icons.calendar_month_outlined),
                  label: const Text(
                    'Add to Meal Plan',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () => _showAddToPlanSheet(context, recipe),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Checklist Header with Progress Indicator & Reset Option
  Widget _buildIngredientChecklistHeader(
    BuildContext context, {
    required int completed,
    required int total,
    required double progress,
    required Recipe recipe,
  }) {
    final theme = Theme.of(context);
    final percent = (progress * 100).toInt();
    final title = Text(
      'Ingredients Checklist',
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 17,
      ),
    );
    final status = Text(
      '$completed of $total ingredients ready ($percent%)',
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: progress == 1.0 ? Colors.green : theme.colorScheme.primary,
      ),
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (completed > 0)
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: Colors.redAccent,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Reset', style: TextStyle(fontSize: 12)),
            onPressed: _resetChecklist,
          ),
        IconButton(
          icon: const Icon(Icons.add_shopping_cart, size: 20),
          tooltip: 'Export ingredients to Grocery List',
          onPressed: () {
            context.read<GroceriesViewModel>().addRecipeIngredients(
              recipe.name,
              recipe.ingredients,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Added ${recipe.ingredients.length} items to Groceries!',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ],
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.35,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 420) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: title),
                        actions,
                      ],
                    ),
                    const SizedBox(height: 2),
                    status,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [title, const SizedBox(height: 2), status],
                    ),
                  ),
                  actions,
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.dividerColor.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress == 1.0 ? Colors.green : theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Interactive Checklist of Ingredients
  Widget _buildIngredientChecklist(List<String> rawIngredients) {
    return Column(
      children: rawIngredients.asMap().entries.map((entry) {
        final index = entry.key;
        final raw = entry.value;
        final parsed = ParsedIngredient.fromString(raw);
        final isChecked = _checkedIndices.contains(index);
        final theme = Theme.of(context);

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isChecked
                ? theme.colorScheme.primary.withValues(alpha: 0.06)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isChecked
                  ? theme.colorScheme.primary.withValues(alpha: 0.3)
                  : theme.dividerColor.withValues(alpha: 0.2),
            ),
          ),
          child: InkWell(
            onTap: () => _toggleIngredient(index),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Checkbox(
                    value: isChecked,
                    activeColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    onChanged: (_) => _toggleIngredient(index),
                  ),
                  const SizedBox(width: 4),
                  // Ingredient Name
                  Expanded(
                    child: Text(
                      parsed.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isChecked
                            ? FontWeight.normal
                            : FontWeight.w600,
                        color: isChecked
                            ? theme.textTheme.bodyMedium?.color?.withValues(
                                alpha: 0.45,
                              )
                            : theme.textTheme.bodyMedium?.color,
                        decoration: isChecked
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Ingredient Quantity badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isChecked
                          ? theme.dividerColor.withValues(alpha: 0.2)
                          : theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      parsed.quantity,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isChecked
                            ? theme.disabledColor
                            : theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // PART 3: Numbered Sequential Instruction Cards
  Widget _buildInstructionCards(List<String> instructions) {
    final theme = Theme.of(context);

    return Column(
      children: instructions.asMap().entries.map((entry) {
        final stepNumber = entry.key + 1;
        final stepText = entry.value;
        final timeCue = RegExp(
          r'\b\d+(?:-\d+)?\s*(?:minutes?|mins?|hours?|hrs?|h)\b',
          caseSensitive: false,
        ).firstMatch(stepText)?.group(0);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.dividerColor.withValues(alpha: 0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Numbered Step Badge
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$stepNumber',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Instruction description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Step $stepNumber',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    if (timeCue != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          timeCue,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      stepText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showAddToPlanSheet(BuildContext context, Recipe recipe) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        MealType selectedMeal = MealType.dinner;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Schedule to Meal Plan',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select meal slot for "${recipe.name}":',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: MealType.values.map((type) {
                      final isSelected = selectedMeal == type;
                      return ChoiceChip(
                        label: Text(type.displayName),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setModalState(() => selectedMeal = type);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        context.read<MealPlannerViewModel>().addMeal(
                          selectedMeal,
                          recipe,
                        );
                        Navigator.pop(sheetContext);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Scheduled to ${selectedMeal.displayName}!',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Text(
                        'Confirm Schedule',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final double width;
  final IconData icon;
  final String title;
  final String value;

  const _HighlightItem({
    required this.width,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _NutritionCard extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _NutritionCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Text(
            unit,
            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
