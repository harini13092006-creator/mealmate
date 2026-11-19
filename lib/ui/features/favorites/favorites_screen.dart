import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/recipe.dart';
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
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 72,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Favorite Recipes Yet',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Explore delicious meals and tap the bookmark or heart icon on any recipe to save it here for quick access.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              icon: const Icon(Icons.search_rounded),
              label: const Text('Explore Recipes'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
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
    );
  }

  Widget _buildFavoritesList(BuildContext context, FavoritesViewModel viewModel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 650;

        if (isWide) {
          final crossAxisCount = constraints.maxWidth > 900 ? 3 : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: viewModel.favoriteRecipes.length,
            itemBuilder: (context, index) {
              final recipe = viewModel.favoriteRecipes[index];
              return _buildRecipeGridCard(context, recipe, viewModel);
            },
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: viewModel.favoriteRecipes.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final recipe = viewModel.favoriteRecipes[index];
            return _buildRecipeListTile(context, recipe, viewModel);
          },
        );
      },
    );
  }

  Widget _buildRecipeListTile(
    BuildContext context,
    Recipe recipe,
    FavoritesViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/recipes/${recipe.id}'),
        child: Row(
          children: [
            // Recipe image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Image.network(
                recipe.imageUrl,
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: 110,
                  height: 110,
                  color: Colors.orange.shade100,
                  child: const Icon(Icons.fastfood, color: Colors.orange),
                ),
              ),
            ),
            // Recipe info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.prepTimeMinutes} min prep • ${recipe.nutrition.calories} kcal',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        recipe.category,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Remove favorite button
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.red),
                tooltip: 'Remove from favorites',
                onPressed: () {
                  viewModel.toggleFavorite(recipe.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Removed "${recipe.name}" from favorites'),
                      duration: const Duration(seconds: 2),
                      behavior: SnackBarBehavior.floating,
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () => viewModel.toggleFavorite(recipe.id),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeGridCard(
    BuildContext context,
    Recipe recipe,
    FavoritesViewModel viewModel,
  ) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => context.push('/recipes/${recipe.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.orange.shade100,
                      child: const Icon(Icons.fastfood, color: Colors.orange),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: CircleAvatar(
                      backgroundColor: Colors.black45,
                      radius: 18,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        tooltip: 'Remove from favorites',
                        onPressed: () {
                          viewModel.toggleFavorite(recipe.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Removed "${recipe.name}" from favorites'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: 'UNDO',
                                onPressed: () => viewModel.toggleFavorite(recipe.id),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${recipe.prepTimeMinutes} mins • ${recipe.nutrition.calories} kcal',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
