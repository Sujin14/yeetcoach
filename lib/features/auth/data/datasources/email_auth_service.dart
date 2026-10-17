import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';

class EmailAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> loginWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      logDebug('Login failed: $e');
      return null;
    }
  }

  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCredential.user?.uid;
      if (uid == null) throw Exception('Sign-up succeeded but user UID is null');
      await _firestore.collection(FirestoreCollections.users).doc(uid).set({
        'email': email,
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return userCredential;
    } catch (e) {
      logDebug('Signup failed: $e');
      return null;
    }
  }

  Future<String?> getRole(String uid) async {
    final doc = await _firestore.collection(FirestoreCollections.users).doc(uid).get();
    return doc.data()?['role'] as String?;
  }

  Future<void> signOut() => _auth.signOut();

  /// Throws [FirebaseAuthException] so callers can map the error code to a message.
  Future<void> sendPasswordResetEmail(String email) => _auth.sendPasswordResetEmail(email: email);
}
