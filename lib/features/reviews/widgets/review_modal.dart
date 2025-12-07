import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../widgets/star_rating.dart';
import '../../../widgets/rounded_pill_button.dart';
import '../../../models/review_model.dart';
import '../../../providers/auth_providers.dart';
import '../../../providers/recipe_providers.dart';
import '../../../providers/review_providers.dart';

class ReviewModal extends ConsumerStatefulWidget {
  final String recipeId;

  const ReviewModal({
    super.key,
    required this.recipeId,
  });

  @override
  ConsumerState<ReviewModal> createState() => _ReviewModalState();
}

class _ReviewModalState extends ConsumerState<ReviewModal> {
  double _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating > 0) {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to review')),
        );
        return;
      }

      setState(() => _isLoading = true);
      try {
        final firestoreService = ref.read(firestoreServiceProvider);
        final userProfile = await firestoreService.getUserProfile(userId);

        final review = ReviewModel(
          id: '', // Will be set by Firestore
          recipeId: widget.recipeId,
          userId: userId,
          userName: userProfile?.displayName,
          userPhotoUrl: userProfile?.photoURL,
          rating: _rating,
          comment: _commentController.text.trim(),
          createdAt: DateTime.now(),
        );

        await firestoreService.createReview(review);

        // Refresh reviews and recipe
        ref.invalidate(recipeReviewsProvider(widget.recipeId));
        ref.invalidate(recipeProvider(widget.recipeId));

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review submitted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide a rating')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusXL),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              margin: const EdgeInsets.only(top: AppConstants.spacingM),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppConstants.spacingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'Write a Review',
                    style: Theme.of(context).textTheme.titleLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Rating
                  Center(
                    child: StarRating(
                      rating: _rating,
                      starSize: 40,
                      allowInteraction: true,
                      onRatingChanged: (rating) {
                        setState(() => _rating = rating);
                      },
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Comment
                  TextField(
                    controller: _commentController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'Share your thoughts about this recipe...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusM,
                        ),
                      ),
                      filled: true,
                      fillColor: AppTheme.cardColor,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),
                  // Submit Button
                  RoundedPillButton(
                    text: 'Submit Review',
                    onPressed: _submitReview,
                    isLoading: _isLoading,
                  ),
                  const SizedBox(height: AppConstants.spacingM),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

