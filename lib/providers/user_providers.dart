import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'auth_providers.dart';
import 'recipe_providers.dart';

// Helper function to create UserModel from Firebase User
UserModel _userModelFromFirebaseUser(User user) {
  return UserModel(
    uid: user.uid,
    email: user.email ?? '',
    displayName: user.displayName,
    photoURL: user.photoURL,
    createdAt: user.metadata.creationTime ?? DateTime.now(),
  );
}

// User Profile Provider with fallback to Firebase Auth
final userProfileProvider =
    StreamProvider.family<UserModel?, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  
  return firestoreService.getUserProfileStream(userId).map((profile) {
    // If Firestore profile exists, return it
    if (profile != null) return profile;
    
    // Fallback to Firebase Auth user data
    final firebaseUser = authService.currentUser;
    if (firebaseUser != null && firebaseUser.uid == userId) {
      return _userModelFromFirebaseUser(firebaseUser);
    }
    return null;
  }).handleError((error, stackTrace) {
    print('Error in userProfileProvider: $error');
    // On error, try to return Firebase Auth data
    final firebaseUser = authService.currentUser;
    if (firebaseUser != null && firebaseUser.uid == userId) {
      return _userModelFromFirebaseUser(firebaseUser);
    }
    return null;
  });
});

// Current User Profile Provider with fallback
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(null);
  }
  
  // Use the family provider directly
  final firestoreService = ref.watch(firestoreServiceProvider);
  final authService = ref.watch(authServiceProvider);
  
  return firestoreService.getUserProfileStream(userId).map((profile) {
    // If Firestore profile exists, return it
    if (profile != null) return profile;
    
    // Fallback to Firebase Auth user data
    final firebaseUser = authService.currentUser;
    if (firebaseUser != null && firebaseUser.uid == userId) {
      return _userModelFromFirebaseUser(firebaseUser);
    }
    return null;
  }).handleError((error, stackTrace) {
    print('Error in currentUserProfileProvider: $error');
    // On error, try to return Firebase Auth data
    final firebaseUser = authService.currentUser;
    if (firebaseUser != null && firebaseUser.uid == userId) {
      return _userModelFromFirebaseUser(firebaseUser);
    }
    return null;
  });
});

