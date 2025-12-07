import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/recipe_model.dart';
import '../models/review_model.dart';
import '../core/constants/app_constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User Operations
  Future<void> createUserProfile(UserModel user) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid)
        .set(user.toMap());
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<UserModel?> getUserProfileStream(String uid) {
    try {
      return _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .snapshots()
          .map((doc) {
        if (doc.exists && doc.data() != null) {
          try {
            return UserModel.fromMap(doc.data()!, doc.id);
          } catch (e) {
            print('Error parsing user profile: $e');
            return null;
          }
        }
        return null;
      }).handleError((error) {
        print('Error fetching user profile: $error');
        return null;
      });
    } catch (e) {
      print('Error in getUserProfileStream: $e');
      return Stream.value(null);
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update(data);
  }

  Future<void> incrementUserStat(String uid, String field) async {
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .update({
      field: FieldValue.increment(1),
    });
  }

  // Recipe Operations
  Future<String> createRecipe(RecipeModel recipe) async {
    final docRef = await _firestore
        .collection(AppConstants.recipesCollection)
        .add(recipe.toMap());
    return docRef.id;
  }

  Future<RecipeModel?> getRecipe(String recipeId) async {
    final doc = await _firestore
        .collection(AppConstants.recipesCollection)
        .doc(recipeId)
        .get();
    if (doc.exists) {
      return RecipeModel.fromMap(doc.data()!, doc.id);
    }
    return null;
  }

  Stream<RecipeModel?> getRecipeStream(String recipeId) {
    return _firestore
        .collection(AppConstants.recipesCollection)
        .doc(recipeId)
        .snapshots()
        .map((doc) {
      if (doc.exists) {
        return RecipeModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  Stream<List<RecipeModel>> getAllRecipes() {
    try {
      return _firestore
          .collection(AppConstants.recipesCollection)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => RecipeModel.fromMap(doc.data(), doc.id))
            .toList();
      }).handleError((error) {
        print('Error fetching recipes: $error');
        return <RecipeModel>[];
      });
    } catch (e) {
      print('Error in getAllRecipes: $e');
      return Stream.value(<RecipeModel>[]);
    }
  }

  Stream<List<RecipeModel>> getRecipesByCategory(String category) {
    if (category == 'All') {
      return getAllRecipes();
    }
    return _firestore
        .collection(AppConstants.recipesCollection)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => RecipeModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Stream<List<RecipeModel>> getUserRecipes(String userId) {
    try {
      return _firestore
          .collection(AppConstants.recipesCollection)
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(50)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => RecipeModel.fromMap(doc.data(), doc.id))
            .toList();
      }).handleError((error) {
        print('Error fetching user recipes: $error');
        // If index error, try without orderBy
        return _firestore
            .collection(AppConstants.recipesCollection)
            .where('authorId', isEqualTo: userId)
            .limit(50)
            .snapshots()
            .map((snapshot) {
          final recipes = snapshot.docs
              .map((doc) => RecipeModel.fromMap(doc.data(), doc.id))
              .toList();
          // Sort manually
          recipes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return recipes;
        });
      });
    } catch (e) {
      print('Error in getUserRecipes: $e');
      return Stream.value(<RecipeModel>[]);
    }
  }

  Future<void> updateRecipe(String recipeId, Map<String, dynamic> data) async {
    await _firestore
        .collection(AppConstants.recipesCollection)
        .doc(recipeId)
        .update(data);
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _firestore
        .collection(AppConstants.recipesCollection)
        .doc(recipeId)
        .delete();
  }

  // Like Operations
  Future<void> toggleLike(String userId, String recipeId) async {
    final likeRef = _firestore
        .collection(AppConstants.recipesCollection)
        .doc(recipeId)
        .collection(AppConstants.likesCollection)
        .doc(userId);

    final likeDoc = await likeRef.get();
    if (likeDoc.exists) {
      await likeRef.delete();
      await _firestore
          .collection(AppConstants.recipesCollection)
          .doc(recipeId)
          .update({
        'likesCount': FieldValue.increment(-1),
      });
    } else {
      await likeRef.set({
        'userId': userId,
        'recipeId': recipeId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _firestore
          .collection(AppConstants.recipesCollection)
          .doc(recipeId)
          .update({
        'likesCount': FieldValue.increment(1),
      });
    }
  }

  Future<bool> isLiked(String userId, String recipeId) async {
    final likeDoc = await _firestore
        .collection(AppConstants.recipesCollection)
        .doc(recipeId)
        .collection(AppConstants.likesCollection)
        .doc(userId)
        .get();
    return likeDoc.exists;
  }

  // Save Operations
  Future<void> toggleSave(String userId, String recipeId) async {
    final saveRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.savesCollection)
        .doc(recipeId);

    final saveDoc = await saveRef.get();
    if (saveDoc.exists) {
      await saveRef.delete();
      await _firestore
          .collection(AppConstants.recipesCollection)
          .doc(recipeId)
          .update({
        'savesCount': FieldValue.increment(-1),
      });
    } else {
      await saveRef.set({
        'recipeId': recipeId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await _firestore
          .collection(AppConstants.recipesCollection)
          .doc(recipeId)
          .update({
        'savesCount': FieldValue.increment(1),
      });
    }
  }

  Future<bool> isSaved(String userId, String recipeId) async {
    final saveDoc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.savesCollection)
        .doc(recipeId)
        .get();
    return saveDoc.exists;
  }

  Stream<List<RecipeModel>> getSavedRecipes(String userId) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId)
        .collection(AppConstants.savesCollection)
        .snapshots()
        .asyncMap((snapshot) async {
      final recipeIds = snapshot.docs.map((doc) => doc.id).toList();
      if (recipeIds.isEmpty) return <RecipeModel>[];
      
      final recipes = <RecipeModel>[];
      for (final id in recipeIds) {
        final recipe = await getRecipe(id);
        if (recipe != null) {
          recipes.add(recipe);
        }
      }
      return recipes;
    });
  }

  // Review Operations
  Future<String> createReview(ReviewModel review) async {
    final docRef = await _firestore
        .collection(AppConstants.reviewsCollection)
        .add(review.toMap());

    // Update recipe rating
    await _updateRecipeRating(review.recipeId);

    return docRef.id;
  }

  Stream<List<ReviewModel>> getRecipeReviews(String recipeId) {
    return _firestore
        .collection(AppConstants.reviewsCollection)
        .where('recipeId', isEqualTo: recipeId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  Future<void> _updateRecipeRating(String recipeId) async {
    final reviewsSnapshot = await _firestore
        .collection(AppConstants.reviewsCollection)
        .where('recipeId', isEqualTo: recipeId)
        .get();

    if (reviewsSnapshot.docs.isEmpty) return;

    double totalRating = 0;
    for (final doc in reviewsSnapshot.docs) {
      totalRating += (doc.data()['rating'] ?? 0.0).toDouble();
    }

    final averageRating = totalRating / reviewsSnapshot.docs.length;

    await _firestore
        .collection(AppConstants.recipesCollection)
        .doc(recipeId)
        .update({
      'rating': averageRating,
      'reviewsCount': reviewsSnapshot.docs.length,
    });
  }
}

