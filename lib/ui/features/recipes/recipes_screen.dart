import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
      body: Column(
        children: [
          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes, ingredients, tags...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: viewModel.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => viewModel.search(''),
                      )
                    : null,
              ),
              onChanged: viewModel.search,
            ),
          ),
          // Categories horizontal scroll
          SizedBox(
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 2,
              alignment: WrapAlignment.center,
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
          const SizedBox(height: 8),
          // Recipe list or grid
          Expanded(
            child: viewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : viewModel.recipes.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
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
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 800
                          ? 3
                          : (constraints.maxWidth > 500 ? 2 : 1);

                      if (crossAxisCount == 1) {
                        return ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: viewModel.recipes.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final recipe = viewModel.recipes[index];
                            return Card(
                              clipBehavior: Clip.antiAlias,
                              child: InkWell(
                                onTap: () =>
                                    context.push('/recipes/${recipe.id}'),
                                child: Row(
                                  children: [
                                    Image(
                                      image:
                                          recipe.imageUrl.startsWith('assets/')
                                          ? AssetImage(recipe.imageUrl)
                                          : NetworkImage(recipe.imageUrl),
                                      width: 110,
                                      height: 110,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => Container(
                                        width: 110,
                                        height: 110,
                                        color: Colors.orange.shade100,
                                        child: const Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.no_photography_outlined,
                                                color: Colors.orange,
                                              ),
                                              Text(
                                                'Photo unavailable',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.brown,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(12),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              recipe.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              '${recipe.prepTimeMinutes} min prep • ${recipe.foodType} • ${recipe.nutrition.calories} kcal',
                                              style: theme.textTheme.bodySmall,
                                            ),
                                            const SizedBox(height: 8),
                                            Wrap(
                                              spacing: 6,
                                              children: recipe.categories.take(2).map((
                                                cat,
                                              ) {
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: theme
                                                        .colorScheme
                                                        .surfaceContainerHighest,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          6,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    cat,
                                                    style: const TextStyle(
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        recipe.isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: recipe.isFavorite
                                            ? Colors.red
                                            : null,
                                      ),
                                      onPressed: () =>
                                          viewModel.toggleFavorite(recipe.id),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: viewModel.recipes.length,
                        itemBuilder: (context, index) {
                          final recipe = viewModel.recipes[index];
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () =>
                                  context.push('/recipes/${recipe.id}'),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image(
                                          image:
                                              recipe.imageUrl.startsWith(
                                                'assets/',
                                              )
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
                                                    Icons
                                                        .no_photography_outlined,
                                                    color: Colors.orange,
                                                  ),
                                                  Text(
                                                    'Photo unavailable',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.brown,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.black45,
                                            radius: 16,
                                            child: IconButton(
                                              padding: EdgeInsets.zero,
                                              iconSize: 18,
                                              icon: Icon(
                                                recipe.isFavorite
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                color: recipe.isFavorite
                                                    ? Colors.red
                                                    : Colors.white,
                                              ),
                                              onPressed: () => viewModel
                                                  .toggleFavorite(recipe.id),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          recipe.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${recipe.prepTimeMinutes} min prep • ${recipe.foodType}',
                                          style: theme.textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
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
