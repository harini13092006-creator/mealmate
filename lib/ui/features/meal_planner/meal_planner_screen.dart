import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/meal_plan.dart';
import '../../../domain/models/recipe.dart';
import '../../core/recipe_cards.dart';
import '../../core/responsive_layout.dart';
import 'meal_planner_view_model.dart';

class MealPlannerScreen extends StatelessWidget {
  const MealPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MealPlannerViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weekly Meal Planner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
            icon: const Icon(Icons.today, size: 18),
            label: const Text(
              'Today',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: viewModel.jumpToToday,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: viewModel.loadPlannerData,
              child: ResponsiveContent(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  children: [
                    // PART 1: Weekly Navigation Bar
                    _buildWeekNavigationHeader(context, viewModel),
                    const SizedBox(height: 12),

                    // 7-Day Calendar Strip (Monday - Sunday)
                    _buildSevenDaySelector(context, viewModel),
                    const SizedBox(height: 16),

                    // Weekly Overview Banner
                    _buildWeeklyOverviewBanner(context, viewModel),
                    const SizedBox(height: 20),

                    // Selected Day Title
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final heading = Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEEE, MMMM d')
                                  .format(viewModel.selectedDate),
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _isSameDay(viewModel.selectedDate, DateTime.now())
                                  ? "Today's Schedule"
                                  : "Planned menu for ${DateFormat('EEEE').format(viewModel.selectedDate)}",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        );
                        final badge = Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${viewModel.getPlannedCountForDay(viewModel.selectedDate)} / 3 Planned',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        );
                        if (constraints.maxWidth < 390) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              heading,
                              const SizedBox(height: 8),
                              Align(
                                alignment: AlignmentDirectional.centerEnd,
                                child: badge,
                              ),
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: heading),
                            badge,
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // PART 2 & 3: Three Daily Meal Categories
                    _buildMealCategorySlot(
                      context,
                      type: MealType.breakfast,
                      assignedMeal: viewModel.getMealForSlot(
                        MealType.breakfast,
                      ),
                      viewModel: viewModel,
                    ),
                    const SizedBox(height: 14),

                    _buildMealCategorySlot(
                      context,
                      type: MealType.lunch,
                      assignedMeal: viewModel.getMealForSlot(MealType.lunch),
                      viewModel: viewModel,
                    ),
                    const SizedBox(height: 14),

                    _buildMealCategorySlot(
                      context,
                      type: MealType.dinner,
                      assignedMeal: viewModel.getMealForSlot(MealType.dinner),
                      viewModel: viewModel,
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // PART 1: Weekly Navigation Interface
  Widget _buildWeekNavigationHeader(
    BuildContext context,
    MealPlannerViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 28),
            tooltip: 'Previous week',
            onPressed: viewModel.previousWeek,
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    viewModel.weekRangeFormatted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 28),
            tooltip: 'Next week',
            onPressed: viewModel.nextWeek,
          ),
        ],
      ),
    );
  }

  // PART 1: 7-Day Calendar Strip (Monday - Sunday)
  Widget _buildSevenDaySelector(
    BuildContext context,
    MealPlannerViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final now = DateTime.now();

    return Row(
      children: viewModel.weekDays.map((day) {
        final isSelected = _isSameDay(day, viewModel.selectedDate);
        final isToday = _isSameDay(day, now);
        final plannedCount = viewModel.getPlannedCountForDay(day);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2.5),
            child: InkWell(
              onTap: () => viewModel.selectDate(day),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : (isToday
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surface),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : (isToday
                              ? theme.colorScheme.primary.withValues(alpha: 0.5)
                              : theme.dividerColor.withValues(alpha: 0.2)),
                    width: isToday && !isSelected ? 1.5 : 1.0,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    // Day of week abbreviation (Mon, Tue, etc.)
                    Text(
                      DateFormat('E').format(day).toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : (isToday
                                  ? theme.colorScheme.primary
                                  : theme.textTheme.bodySmall?.color),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Day date number
                    Text(
                      '${day.day}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Planned meal indicator dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (dotIndex) {
                        final hasMeal = plannedCount > dotIndex;
                        return Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? (hasMeal ? Colors.white : Colors.white24)
                                : (hasMeal
                                      ? theme.colorScheme.primary
                                      : Colors.transparent),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // PART 5: Weekly Overview Banner
  Widget _buildWeeklyOverviewBanner(
    BuildContext context,
    MealPlannerViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final totalPlanned = viewModel.weekMeals.length;
    const maxMeals = 21; // 7 days * 3 meals
    final double percent = totalPlanned / maxMeals;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.9),
            theme.colorScheme.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Weekly Plan Status',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '$totalPlanned of $maxMeals planned',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percent,
                    minHeight: 6,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PART 2 & 3: Meal Category Slot (Breakfast, Lunch, Dinner)
  Widget _buildMealCategorySlot(
    BuildContext context, {
    required MealType type,
    required PlannedMeal? assignedMeal,
    required MealPlannerViewModel viewModel,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Slot Header (Icon + Meal Category + Add Action)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getMealTypeIcon(type),
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      type.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                if (assignedMeal == null)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                    ),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: Text(
                      'Add ${type.displayName}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () =>
                        _openRecipePicker(context, type, viewModel),
                  )
                else
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                    label: const Text(
                      'Replace',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onPressed: () => _openRecipePicker(
                      context,
                      type,
                      viewModel,
                      existingMealId: assignedMeal.id,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Slot Content: Assigned Meal Card or Empty State
          Padding(
            padding: const EdgeInsets.all(12),
            child: assignedMeal == null
                ? _buildEmptyMealSlot(context, type, viewModel)
                : _buildAssignedMealCard(context, assignedMeal, viewModel),
          ),
        ],
      ),
    );
  }

  // PART 5: Empty-State Card
  Widget _buildEmptyMealSlot(
    BuildContext context,
    MealType type,
    MealPlannerViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _openRecipePicker(context, type, viewModel),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.25,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.3),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'No ${type.displayName.toLowerCase()} scheduled yet. Tap to add recipe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PART 3: Assigned Meal Card
  Widget _buildAssignedMealCard(
    BuildContext context,
    PlannedMeal planned,
    MealPlannerViewModel viewModel,
  ) {
    final theme = Theme.of(context);
    final recipe = planned.recipe;
    final image = ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 68,
        height: 68,
        child: RecipeImage(
          imageUrl: recipe.imageUrl,
          cacheWidth: (68 * MediaQuery.devicePixelRatioOf(context)).round(),
        ),
      ),
    );
    final info = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          recipe.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            decoration: planned.isCompleted ? TextDecoration.lineThrough : null,
            color: planned.isCompleted ? Colors.grey : null,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 2,
          children: [
            Text(
              '${recipe.prepTimeMinutes}m prep',
              style: theme.textTheme.bodySmall,
            ),
            Text(
              '${recipe.nutrition.calories} kcal',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 5),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              recipe.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: Icon(
            planned.isCompleted
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: planned.isCompleted ? Colors.green : Colors.grey,
            size: 22,
          ),
          tooltip: planned.isCompleted ? 'Mark as not eaten' : 'Mark as eaten',
          onPressed: () => viewModel.toggleCompleted(planned.id),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(
            Icons.delete_outline_rounded,
            size: 20,
            color: Colors.redAccent,
          ),
          tooltip: 'Remove from plan',
          onPressed: () => _confirmRemoveMeal(context, planned, viewModel),
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) => Container(
        decoration: BoxDecoration(
          color: planned.isCompleted
              ? theme.colorScheme.primary.withValues(alpha: 0.04)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: planned.isCompleted
                ? Colors.green.withValues(alpha: 0.3)
                : theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/recipes/${recipe.id}'),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: constraints.maxWidth < 440
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          image,
                          const SizedBox(width: 10),
                          Expanded(child: info),
                        ],
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerEnd,
                        child: actions,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      image,
                      const SizedBox(width: 12),
                      Expanded(child: info),
                      actions,
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Remove confirmation
  void _confirmRemoveMeal(
    BuildContext context,
    PlannedMeal planned,
    MealPlannerViewModel viewModel,
  ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove from Plan'),
          content: Text(
            'Remove "${planned.recipe.name}" from ${planned.mealType.displayName}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                viewModel.removeMeal(planned.id);
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Removed ${planned.recipe.name}'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  // PART 2: Recipe Selection Bottom Sheet with Live Search & Categories
  void _openRecipePicker(
    BuildContext context,
    MealType mealType,
    MealPlannerViewModel viewModel, {
    String? existingMealId,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _RecipePickerSheet(
          mealType: mealType,
          selectedDate: viewModel.selectedDate,
          recipes: viewModel.availableRecipes,
          onRecipeSelected: (recipe) {
            if (existingMealId != null) {
              viewModel.replaceMeal(existingMealId, recipe);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Replaced with ${recipe.name}'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            } else {
              viewModel.addMeal(mealType, recipe);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Added ${recipe.name} to ${mealType.displayName}!',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      },
    );
  }

  IconData _getMealTypeIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny_rounded;
      case MealType.lunch:
        return Icons.lunch_dining_rounded;
      case MealType.dinner:
        return Icons.dinner_dining_rounded;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// Interactive Recipe Picker Bottom Sheet
class _RecipePickerSheet extends StatefulWidget {
  final MealType mealType;
  final DateTime selectedDate;
  final List<Recipe> recipes;
  final ValueChanged<Recipe> onRecipeSelected;

  const _RecipePickerSheet({
    required this.mealType,
    required this.selectedDate,
    required this.recipes,
    required this.onRecipeSelected,
  });

  @override
  State<_RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<_RecipePickerSheet> {
  String _searchQuery = '';
  String _selectedCategory = 'All';

  final List<String> _categories = const [
    'All',
    'Quick Meals',
    'Healthy Bowls',
    'Desserts',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    // Filter recipes dynamically
    final filteredRecipes = widget.recipes.where((recipe) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          recipe.name.toLowerCase().contains(_searchQuery.toLowerCase().trim());
      final matchesCategory =
          _selectedCategory == 'All' ||
          recipe.category.toLowerCase() == _selectedCategory.toLowerCase();
      return matchesSearch && matchesCategory;
    }).toList();

    return Container(
      height: mediaQuery.size.height * 0.82,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: theme.dividerColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Sheet Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assign to ${widget.mealType.displayName}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMM d').format(widget.selectedDate),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search 24+ recipes by name...',
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Category Chips
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedCategory = cat);
                  },
                  selectedColor: theme.colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : null,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1),

          // Recipe List
          Expanded(
            child: filteredRecipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: 12),
                        const Text('No recipes match your filter'),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRecipes.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final recipe = filteredRecipes[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: theme.dividerColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              recipe.imageUrl,
                              width: 52,
                              height: 52,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => Container(
                                width: 52,
                                height: 52,
                                color: Colors.orange.shade100,
                                child: const Icon(
                                  Icons.fastfood,
                                  color: Colors.orange,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            recipe.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '${recipe.category} • ${recipe.prepTimeMinutes}m prep • ${recipe.nutrition.calories} kcal',
                            style: theme.textTheme.bodySmall,
                          ),
                          trailing: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              widget.onRecipeSelected(recipe);
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Assign',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
