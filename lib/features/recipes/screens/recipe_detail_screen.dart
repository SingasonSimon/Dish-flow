import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/star_rating.dart';
import '../../../providers/recipe_providers.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/review_providers.dart';
import '../../reviews/widgets/review_modal.dart';

class RecipeDetailScreen extends ConsumerStatefulWidget {
  final String recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  ConsumerState<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends ConsumerState<RecipeDetailScreen> {
  final bool _ingredientsExpanded = true;
  final bool _stepsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final recipeAsync = ref.watch(recipeProvider(widget.recipeId));
    final userId = ref.watch(currentUserIdProvider);
    final isLikedAsync = userId != null
        ? ref.watch(isLikedProvider({'userId': userId, 'recipeId': widget.recipeId}))
        : null;
    final isSavedAsync = userId != null
        ? ref.watch(isSavedProvider({'userId': userId, 'recipeId': widget.recipeId}))
        : null;
    final reviewsAsync = ref.watch(recipeReviewsProvider(widget.recipeId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: recipeAsync.when(
        data: (recipe) {
          if (recipe == null) {
            return const Center(child: Text('Recipe not found'));
          }

          return CustomScrollView(
            slivers: [
              // Hero Image
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      recipe.imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: recipe.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: AppTheme.cardColor,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: AppTheme.cardColor,
                                child: const Icon(
                                  Icons.image,
                                  size: 100,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            )
                          : Container(
                              color: AppTheme.cardColor,
                              child: const Icon(
                                Icons.image,
                                size: 100,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                      // Gradient Overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                actions: [
                  if (userId != null)
                    isSavedAsync?.when(
                      data: (isSaved) => IconButton(
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.white,
                        ),
                        onPressed: () async {
                          final firestoreService = ref.read(firestoreServiceProvider);
                          await firestoreService.toggleSave(userId, widget.recipeId);
                          ref.invalidate(isSavedProvider({'userId': userId, 'recipeId': widget.recipeId}));
                        },
                      ),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ) ?? const SizedBox.shrink(),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.white),
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                  ),
                ],
              ),
              // Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and Info
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipe.title,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          if (recipe.description != null) ...[
                            const SizedBox(height: AppConstants.spacingS),
                            Text(
                              recipe.description!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: AppConstants.spacingS),
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundImage: recipe.authorName != null
                                    ? null
                                    : null, // TODO: Add author photo URL
                                child: const Icon(Icons.person, size: 20),
                              ),
                              const SizedBox(width: AppConstants.spacingS),
                              Text(
                                recipe.authorName ?? 'Unknown',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: AppConstants.spacingM),
                              StarRating(rating: recipe.rating, starSize: 16),
                              const SizedBox(width: AppConstants.spacingXS),
                              Text(
                                '${recipe.rating.toStringAsFixed(1)} (${recipe.reviewsCount} reviews)',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spacingL),
                          // Action Buttons
                          Row(
                            children: [
                              if (userId != null)
                                Expanded(
                                  child: isLikedAsync?.when(
                                    data: (isLiked) => OutlinedButton.icon(
                                      onPressed: () async {
                                        final firestoreService = ref.read(firestoreServiceProvider);
                                        await firestoreService.toggleLike(userId, widget.recipeId);
                                        ref.invalidate(isLikedProvider({'userId': userId, 'recipeId': widget.recipeId}));
                                        ref.invalidate(recipeProvider(widget.recipeId));
                                      },
                                      icon: Icon(
                                        isLiked
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isLiked
                                            ? AppTheme.errorColor
                                            : AppTheme.textSecondary,
                                      ),
                                      label: Text('${recipe.likesCount}'),
                                      style: OutlinedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: AppConstants.spacingM,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppConstants.radiusM,
                                          ),
                                        ),
                                      ),
                                    ),
                                    loading: () => const OutlinedButton(
                                      onPressed: null,
                                      child: Text('Like'),
                                    ),
                                    error: (_, __) => const OutlinedButton(
                                      onPressed: null,
                                      child: Text('Like'),
                                    ),
                                  ) ?? const SizedBox.shrink(),
                                ),
                              const SizedBox(width: AppConstants.spacingM),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: userId != null
                                      ? () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => ReviewModal(
                                              recipeId: widget.recipeId,
                                            ),
                                          );
                                        }
                                      : null,
                                  icon: const Icon(Icons.rate_review),
                                  label: const Text('Review'),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: AppConstants.spacingM,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.radiusM,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Ingredients Section
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingL,
                        vertical: AppConstants.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: _ingredientsExpanded,
                        title: Text(
                          'Ingredients',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppConstants.spacingL),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: recipe.ingredients.map((ingredient) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppConstants.spacingS,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: AppConstants.spacingM),
                                      Expanded(
                                        child: Text(
                                          ingredient,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Steps Section
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingL,
                        vertical: AppConstants.spacingS,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceColor,
                        borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      ),
                      child: ExpansionTile(
                        initiallyExpanded: _stepsExpanded,
                        title: Text(
                          'Instructions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(AppConstants.spacingL),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: recipe.steps.asMap().entries.map((entry) {
                                final index = entry.key;
                                final step = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppConstants.spacingL,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryColor,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${index + 1}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: AppConstants.spacingM),
                                      Expanded(
                                        child: Text(
                                          step,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Reviews Section
                    Padding(
                      padding: const EdgeInsets.all(AppConstants.spacingL),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Reviews',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppConstants.spacingM),
                          reviewsAsync.when(
                            data: (reviews) {
                              if (reviews.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      AppConstants.spacingXL,
                                    ),
                                    child: Text(
                                      'No reviews yet. Be the first to review!',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                  ),
                                );
                              }
                              return Column(
                                children: reviews.map((review) {
                                  return Container(
                                    margin: const EdgeInsets.only(
                                      bottom: AppConstants.spacingM,
                                    ),
                                    padding: const EdgeInsets.all(
                                      AppConstants.spacingL,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.surfaceColor,
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.radiusL,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundImage:
                                                  review.userPhotoUrl != null
                                                      ? NetworkImage(
                                                          review.userPhotoUrl!)
                                                      : null,
                                              child: review.userPhotoUrl == null
                                                  ? const Icon(Icons.person)
                                                  : null,
                                            ),
                                            const SizedBox(
                                              width: AppConstants.spacingM,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    review.userName ?? 'Anonymous',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .titleSmall,
                                                  ),
                                                  StarRating(
                                                    rating: review.rating,
                                                    starSize: 16,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Text(
                                              _formatDate(review.createdAt),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: AppConstants.spacingM,
                                        ),
                                        Text(
                                          review.comment,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (error, stack) => Text(
                              'Error loading reviews: $error',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingXL),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (error, stack) => Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                const SizedBox(height: AppConstants.spacingM),
                Text('Error loading recipe: $error'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else {
      return 'Just now';
    }
  }
}

