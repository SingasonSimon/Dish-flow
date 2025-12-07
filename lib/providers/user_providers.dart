import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'auth_providers.dart';
import 'recipe_providers.dart';

// User Profile Provider
final userProfileProvider =
    StreamProvider.family<UserModel?, String>((ref, userId) {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserProfileStream(userId);
});

// Current User Profile Provider
final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) {
    return Stream.value(null);
  }
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getUserProfileStream(userId);
});

