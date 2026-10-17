import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:yeetcoach/core/constants/firestore_collections.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';

class GoogleAuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  GoogleAuthService({FirebaseAuth? auth, GoogleSignIn? googleSignIn, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // GoogleSignIn.initialize() must complete exactly once per app before any other call,
  // so the pending future is shared across instances and cleared if it fails.
  static Future<void>? _initialization;

  Future<void> _ensureInitialized() async {
    final pending = _initialization ??= _googleSignIn.initialize();
    try {
      await pending;
    } catch (_) {
      _initialization = null;
      rethrow;
    }
  }

  /// Returns the logged-in [User], or null if the user cancelled the picker.
  /// Throws on network/auth failure.
  Future<User?> loginWithGoogle() async {
    await _ensureInitialized();

    final GoogleSignInAccount googleUser;
    try {
      googleUser = await _googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        // Android also reports a missing SHA-1 / OAuth client as "canceled" ("[16] Account reauth failed").
        logDebug('GoogleAuthService: sign-in canceled: ${e.description}');
        return null;
      }
      rethrow;
    }

    final credential = GoogleAuthProvider.credential(
      idToken: googleUser.authentication.idToken,
    );

    final result = await _auth.signInWithCredential(credential);
    final user = result.user;
    logDebug('GoogleAuthService: logged in as ${user?.email}');
    if (user != null) await _ensureUserDocument(user);
    return user;
  }

  /// Google accounts skip email sign-up, so users/{uid} may not exist yet.
  /// An existing document (e.g. a YeetFit account) is left untouched.
  /// role is assigned server-side; Firestore rules reject a client-created doc that sets it.
  Future<void> _ensureUserDocument(User user) async {
    final ref = _firestore.collection(FirestoreCollections.users).doc(user.uid);
    if ((await ref.get()).exists) return;
    await ref.set({
      'uid': user.uid,
      'email': user.email,
      'name': user.displayName,
      'profilePicture': user.photoURL,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    logDebug('GoogleAuthService: created users/${user.uid}');
  }

  /// Signs out from both Firebase Auth and the Google account chooser,
  /// so the account picker reappears on next login.
  /// Firebase sign-out always runs first; a Google sign-out failure is only logged.
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _ensureInitialized();
      await _googleSignIn.signOut();
    } catch (e) {
      logDebug('GoogleAuthService: Google sign-out failed: $e');
    }
  }
}
