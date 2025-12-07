import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/review_model.dart';
import '../services/firestore_service.dart';

// Recipe Reviews Provider
final recipeReviewsProvider =
    StreamProvider.family<List<ReviewModel>, String>((ref, recipeId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getRecipeReviews(recipeId);
});

