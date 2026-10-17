import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRepository {
  Future<UserCredential?> loginWithEmail(String email, String password);
  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String name,
  );
  /// Returns users/{uid}.role, or null when the document or field is missing.
  Future<String?> getRole(String uid);
  Future<void> signOut();

  /// Returns the logged-in User, or null if the user cancelled.
  Future<User?> loginWithGoogle();

  /// Signs out from both Firebase Auth and the Google session.
  Future<void> signOutGoogle();

  /// Throws [FirebaseAuthException] on failure.
  Future<void> sendPasswordResetEmail(String email);
}
