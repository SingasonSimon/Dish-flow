import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  // Auth State Stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Current User
  User? get currentUser => _auth.currentUser;

  // Sign In with Email and Password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Register with Email and Password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await credential.user?.updateDisplayName(displayName);

      // Create user profile in Firestore
      if (credential.user != null) {
        final userModel = UserModel(
          uid: credential.user!.uid,
          email: email,
          displayName: displayName,
          createdAt: DateTime.now(),
        );
        await _firestoreService.createUserProfile(userModel);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Sign In with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null; // User cancelled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _auth.signInWithCredential(credential);

      // Create user profile in Firestore if new user
      if (userCredential.user != null &&
          userCredential.additionalUserInfo?.isNewUser == true) {
        final userModel = UserModel(
          uid: userCredential.user!.uid,
          email: userCredential.user!.email ?? '',
          displayName: userCredential.user!.displayName,
          photoURL: userCredential.user!.photoURL,
          createdAt: DateTime.now(),
        );
        await _firestoreService.createUserProfile(userModel);
      }

      return userCredential;
    } catch (e) {
      throw Exception('Google sign-in failed: $e');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  // Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Update User Profile
  Future<void> updateUserProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updateDisplayName(displayName);
        if (photoURL != null) {
          await user.updatePhotoURL(photoURL);
        }
        await user.reload();
      }
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Handle Auth Exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for that email.';
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is invalid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }
}

