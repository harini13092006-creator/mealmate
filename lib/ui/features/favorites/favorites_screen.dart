import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/recipe_cards.dart';
import '../../core/responsive_layout.dart';
import 'favorites_view_model.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<FavoritesViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (viewModel.favoriteRecipes.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${viewModel.favoriteRecipes.length} saved',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.favoriteRecipes.isEmpty
          ? _buildEmptyState(context)
          : _buildFavoritesList(context, viewModel),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 440),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_border_rounded,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'No Favorite Recipes Yet',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Explore delicious meals and tap the bookmark or heart icon on any recipe to save it here for quick access.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                icon: const Icon(Icons.search_rounded),
                label: const Text('Explore Recipes'),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/recipes');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList(
    BuildContext context,
    FavoritesViewModel viewModel,
  ) {
    return ResponsiveContent(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final columns = AppBreakpoints.gridColumns(constraints.maxWidth);
          final horizontalPadding = AppBreakpoints.pagePadding(
            constraints.maxWidth,
          );

          if (columns == 1) {
            return ListView.separated(
              padding: EdgeInsets.all(horizontalPadding),
              itemCount: viewModel.favoriteRecipes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final recipe = viewModel.favoriteRecipes[index];
                return RecipeListCard(
                  recipe: recipe,
                  onTap: () => context.push('/recipes/${recipe.id}'),
                  favoriteTooltip: 'Remove from favorites',
                  onFavoriteTap: () => _removeFavorite(
                    context,
                    recipe.id,
                    recipe.name,
                    viewModel,
                  ),
                );
              },
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(horizontalPadding),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.76,
            ),
            itemCount: viewModel.favoriteRecipes.length,
            itemBuilder: (context, index) {
              final recipe = viewModel.favoriteRecipes[index];
              return RecipeGridCard(
                recipe: recipe,
                onTap: () => context.push('/recipes/${recipe.id}'),
                favoriteTooltip: 'Remove from favorites',
                onFavoriteTap: () =>
                    _removeFavorite(context, recipe.id, recipe.name, viewModel),
              );
            },
          );
        },
      ),
    );
  }

  void _removeFavorite(
    BuildContext context,
    String recipeId,
    String recipeName,
    FavoritesViewModel viewModel,
  ) {
    viewModel.toggleFavorite(recipeId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Removed "$recipeName" from favorites'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => viewModel.toggleFavorite(recipeId),
        ),
      ),
    );
  }
}
