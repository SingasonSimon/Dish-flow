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
      if (credential.user != null && displayName.isNotEmpty) {
        try {
          await credential.user!.updateDisplayName(displayName);
          await credential.user!.reload();
        } catch (e) {
          print('Warning: Failed to update display name: $e');
        }
      }

      // Create user profile in Firestore (non-blocking)
      if (credential.user != null) {
        // Don't await - let it run in background
        _firestoreService.getUserProfile(credential.user!.uid).then((existingProfile) {
          if (existingProfile == null) {
            final userModel = UserModel(
              uid: credential.user!.uid,
              email: email,
              displayName: displayName,
              createdAt: DateTime.now(),
            );
            _firestoreService.createUserProfile(userModel).catchError((e) {
              print('Warning: Failed to create user profile: $e');
            });
          } else if (displayName.isNotEmpty && existingProfile.displayName != displayName) {
            _firestoreService.updateUserProfile(credential.user!.uid, {
              'displayName': displayName,
            }).catchError((e) {
              print('Warning: Failed to update user profile: $e');
            });
          }
        }).catchError((e) {
          print('Warning: Failed to check user profile: $e');
        });
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

      // Create or update user profile in Firestore (non-blocking)
      if (userCredential.user != null) {
        final firebaseUser = userCredential.user!;
        // Don't await - let it run in background
        _firestoreService.getUserProfile(firebaseUser.uid).then((existingProfile) {
          if (existingProfile == null || userCredential.additionalUserInfo?.isNewUser == true) {
            final userModel = UserModel(
              uid: firebaseUser.uid,
              email: firebaseUser.email ?? '',
              displayName: firebaseUser.displayName,
              photoURL: firebaseUser.photoURL,
              createdAt: DateTime.now(),
            );
            _firestoreService.createUserProfile(userModel).catchError((e) {
              print('Warning: Failed to create user profile: $e');
            });
          } else {
            // Update profile with latest Firebase Auth data
            final updates = <String, dynamic>{};
            if (firebaseUser.displayName != null && existingProfile.displayName != firebaseUser.displayName) {
              updates['displayName'] = firebaseUser.displayName;
            }
            if (firebaseUser.photoURL != null && existingProfile.photoURL != firebaseUser.photoURL) {
              updates['photoURL'] = firebaseUser.photoURL;
            }
            if (updates.isNotEmpty) {
              _firestoreService.updateUserProfile(firebaseUser.uid, updates).catchError((e) {
                print('Warning: Failed to update user profile: $e');
              });
            }
          }
        }).catchError((e) {
          print('Warning: Failed to check user profile: $e');
        });
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Google sign-in failed: ${e.toString()}');
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
  Exception _handleAuthException(FirebaseAuthException e) {
    String message;
    switch (e.code) {
      case 'weak-password':
        message = 'The password provided is too weak.';
        break;
      case 'email-already-in-use':
        message = 'An account already exists for that email.';
        break;
      case 'user-not-found':
        message = 'No user found for that email.';
        break;
      case 'wrong-password':
        message = 'Wrong password provided.';
        break;
      case 'invalid-email':
        message = 'The email address is invalid.';
        break;
      case 'user-disabled':
        message = 'This user account has been disabled.';
        break;
      case 'too-many-requests':
        message = 'Too many requests. Please try again later.';
        break;
      case 'operation-not-allowed':
        message = 'This operation is not allowed.';
        break;
      default:
        message = e.message ?? 'An error occurred during authentication.';
    }
    return Exception(message);
  }
}


