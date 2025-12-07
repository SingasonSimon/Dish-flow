import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class RecipeCard extends StatelessWidget {
  final String id;
  final String title;
  final String? imageUrl;
  final String? authorName;
  final int likesCount;
  final double? rating;
  final VoidCallback? onTap;

  const RecipeCard({
    super.key,
    required this.id,
    required this.title,
    this.imageUrl,
    this.authorName,
    this.likesCount = 0,
    this.rating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.spacingM),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
          child: Stack(
            children: [
              // Image
              AspectRatio(
                aspectRatio: 16 / 9,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.cardColor,
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: AppTheme.cardColor,
                          child: const Icon(Icons.error),
                        ),
                      )
                    : Container(
                        color: AppTheme.cardColor,
                        child: const Icon(
                          Icons.image,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                      ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: Container(
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
              ),
              // Content
              Positioned(
                left: AppConstants.spacingM,
                right: AppConstants.spacingM,
                bottom: AppConstants.spacingM,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Row(
                      children: [
                        if (authorName != null) ...[
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: AppConstants.spacingXS),
                          Text(
                            authorName!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                          ),
                          const SizedBox(width: AppConstants.spacingM),
                        ],
                        Icon(
                          Icons.favorite_outline,
                          size: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: AppConstants.spacingXS),
                        Text(
                          '$likesCount',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                        ),
                        if (rating != null) ...[
                          const SizedBox(width: AppConstants.spacingM),
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          const SizedBox(width: AppConstants.spacingXS),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

