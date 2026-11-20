import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/recipe_cards.dart';
import '../../core/responsive_layout.dart';
import 'recipes_view_model.dart';

class RecipesScreen extends StatelessWidget {
  const RecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<RecipesViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Discovery'),
        actions: [
          IconButton(
            icon: Icon(
              viewModel.showFavoritesOnly
                  ? Icons.favorite
                  : Icons.favorite_border,
              color: viewModel.showFavoritesOnly ? Colors.red : null,
            ),
            tooltip: 'Filter Favorites',
            onPressed: viewModel.toggleFavoritesFilter,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ResponsiveContent(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search recipes, ingredients, tags...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: viewModel.search,
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: viewModel.categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = viewModel.categories[index];
                    final isSelected = viewModel.selectedCategory == category;
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) => viewModel.setCategory(category),
                      selectedColor: theme.colorScheme.primaryContainer,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    );
                  },
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 2,
                  alignment: WrapAlignment.start,
                  children: [
                    _filter(context, viewModel.selectedCuisine, const [
                      'All cuisines',
                      'South Indian',
                      'North Indian',
                      'East Indian',
                      'West Indian',
                    ], viewModel.setCuisine),
                    _filter(context, viewModel.selectedFoodType, const [
                      'All types',
                      'Vegetarian',
                      'Non-Vegetarian',
                    ], viewModel.setFoodType),
                    _filter(context, viewModel.sortBy, const [
                      'Recently added',
                      'Preparation time',
                      'Recipe name',
                    ], viewModel.setSortBy),
                  ],
                ),
              ),
            ),
            if (viewModel.isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (viewModel.recipes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 56,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No recipes found',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Try adjusting your search or category filter',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  final columns = AppBreakpoints.gridColumns(width);
                  final padding = AppBreakpoints.pagePadding(width);

                  if (columns == 1) {
                    return SliverPadding(
                      padding: EdgeInsets.fromLTRB(padding, 8, padding, 24),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: RecipeListCard(
                              recipe: viewModel.recipes[index],
                              onTap: () => context.push(
                                '/recipes/${viewModel.recipes[index].id}',
                              ),
                              onFavoriteTap: () => viewModel.toggleFavorite(
                                viewModel.recipes[index].id,
                              ),
                            ),
                          ),
                          childCount: viewModel.recipes.length,
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.all(padding),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.76,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => RecipeGridCard(
                          recipe: viewModel.recipes[index],
                          onTap: () => context.push(
                            '/recipes/${viewModel.recipes[index].id}',
                          ),
                          onFavoriteTap: () => viewModel.toggleFavorite(
                            viewModel.recipes[index].id,
                          ),
                        ),
                        childCount: viewModel.recipes.length,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _filter(
    BuildContext context,
    String value,
    List<String> values,
    ValueChanged<String> onChanged,
  ) => DropdownButton<String>(
    value: value,
    underline: const SizedBox.shrink(),
    items: values
        .map((item) => DropdownMenuItem(value: item, child: Text(item)))
        .toList(),
    onChanged: (next) {
      if (next != null) onChanged(next);
    },
  );
}
