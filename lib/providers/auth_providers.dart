import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth State Stream Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.valueOrNull;
});

// Current User ID Provider
final currentUserIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.uid;
});

