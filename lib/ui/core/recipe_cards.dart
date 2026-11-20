import 'package:flutter/material.dart';

import '../../domain/models/recipe.dart';

class RecipeImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final int? cacheWidth;

  const RecipeImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.cacheWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _fallback();

    final ImageProvider<Object> provider = imageUrl.startsWith('assets/')
        ? AssetImage(imageUrl)
        : NetworkImage(imageUrl);

    return Image(
      image: cacheWidth == null
          ? provider
          : ResizeImage(provider, width: cacheWidth),
      fit: fit,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  Widget _fallback() => ColoredBox(
    color: Colors.orange.shade100,
    child: const Center(
      child: Icon(Icons.restaurant_rounded, color: Colors.deepOrange),
    ),
  );
}

class RecipeListCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final String favoriteTooltip;

  const RecipeListCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onFavoriteTap,
    this.favoriteTooltip = 'Toggle favorite',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageWidth = (constraints.maxWidth * 0.28).clamp(76.0, 104.0);
        final dpr = MediaQuery.devicePixelRatioOf(context);

        return Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: onTap,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: imageWidth,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: RecipeImage(
                      imageUrl: recipe.imageUrl,
                      cacheWidth: (imageWidth * dpr).round(),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          recipe.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Wrap(
                          spacing: 10,
                          runSpacing: 2,
                          children: [
                            _RecipeMeta(
                              icon: Icons.schedule_rounded,
                              text: '${recipe.prepTimeMinutes}m prep',
                            ),
                            _RecipeMeta(
                              icon: Icons.local_fire_department_rounded,
                              text: '${recipe.nutrition.calories} kcal',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (onFavoriteTap != null)
                  IconButton(
                    tooltip: favoriteTooltip,
                    onPressed: onFavoriteTap,
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      recipe.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: recipe.isFavorite
                          ? Colors.redAccent
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class RecipeGridCard extends StatelessWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final String favoriteTooltip;

  const RecipeGridCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onFavoriteTap,
    this.favoriteTooltip = 'Toggle favorite',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final imageHeight = constraints.maxWidth / 1.3;
                return SizedBox(
                  height: imageHeight,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RecipeImage(
                        imageUrl: recipe.imageUrl,
                        cacheWidth: (constraints.maxWidth * dpr).round(),
                      ),
                      Positioned(
                        left: 8,
                        bottom: 8,
                        right: onFavoriteTap == null ? 8 : 48,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.68),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              recipe.category,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (onFavoriteTap != null)
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Material(
                            color: Colors.black54,
                            shape: const CircleBorder(),
                            child: IconButton(
                              tooltip: favoriteTooltip,
                              onPressed: onFavoriteTap,
                              visualDensity: VisualDensity.compact,
                              iconSize: 19,
                              color: Colors.white,
                              icon: Icon(
                                recipe.isFavorite
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: recipe.isFavorite
                                    ? Colors.redAccent
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Wrap(
                      spacing: 8,
                      runSpacing: 2,
                      children: [
                        _RecipeMeta(
                          icon: Icons.schedule_rounded,
                          text: '${recipe.prepTimeMinutes}m',
                        ),
                        _RecipeMeta(
                          icon: Icons.local_fire_department_rounded,
                          text: '${recipe.nutrition.calories} kcal',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeMeta extends StatelessWidget {
  final IconData icon;
  final String text;

  const _RecipeMeta({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: theme.colorScheme.primary),
        const SizedBox(width: 3),
        Text(text, style: theme.textTheme.labelSmall),
      ],
    );
  }
}
