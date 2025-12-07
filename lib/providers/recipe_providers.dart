import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe_model.dart';
import '../services/firestore_service.dart';

// Firestore Service Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// All Recipes Stream Provider
final recipesProvider = StreamProvider<List<RecipeModel>>((ref) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getAllRecipes();
});

// Recipes by Category Provider
final recipesByCategoryProvider =
    StreamProvider.family<List<RecipeModel>, String>((ref, category) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getRecipesByCategory(category);
});

// Single Recipe Provider
final recipeProvider =
    StreamProvider.family<RecipeModel?, String>((ref, recipeId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getRecipeStream(recipeId);
});

// User Recipes Provider
final userRecipesProvider =
    StreamProvider.family<List<RecipeModel>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserRecipes(userId);
});

// Saved Recipes Provider
final savedRecipesProvider =
    StreamProvider.family<List<RecipeModel>, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getSavedRecipes(userId);
});

// Like Status Provider
final isLikedProvider = FutureProvider.family<bool, Map<String, String>>(
  (ref, params) async {
    final firestoreService = ref.watch(firestoreServiceProvider);
    return firestoreService.isLiked(params['userId']!, params['recipeId']!);
  },
);

// Save Status Provider
final isSavedProvider = FutureProvider.family<bool, Map<String, String>>(
  (ref, params) async {
    final firestoreService = ref.watch(firestoreServiceProvider);
    return firestoreService.isSaved(params['userId']!, params['recipeId']!);
  },
);

