import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/email_auth_service.dart';
import '../datasources/google_auth_service.dart';

class AuthRepositoryImpl implements AuthRepository {
  final EmailAuthService emailService;
  final GoogleAuthService _googleAuthService;

  AuthRepositoryImpl(this.emailService, {GoogleAuthService? googleAuthService})
      : _googleAuthService = googleAuthService ?? GoogleAuthService();

  @override
  Future<UserCredential?> loginWithEmail(String email, String password) {
    return emailService.loginWithEmail(email, password);
  }

  @override
  Future<UserCredential?> signUpWithEmail(
    String email,
    String password,
    String name,
  ) {
    return emailService.signUpWithEmail(email, password, name);
  }

  @override
  Future<String?> getRole(String uid) {
    return emailService.getRole(uid);
  }

  @override
  Future<void> signOut() {
    return emailService.signOut();
  }

  @override
  Future<User?> loginWithGoogle() => _googleAuthService.loginWithGoogle();

  @override
  Future<void> signOutGoogle() => _googleAuthService.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) => emailService.sendPasswordResetEmail(email);
}
