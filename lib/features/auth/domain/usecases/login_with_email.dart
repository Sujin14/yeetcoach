import '../../domain/repositories/auth_repository.dart';

class LoginWithEmail {
  final AuthRepository repository;

  LoginWithEmail(this.repository);

  /// Returns the logged-in uid, or null if login failed.
  /// The role check happens after routing, once the coach profile is known to exist.
  Future<String?> call(String email, String password) async {
    final userCredential = await repository.loginWithEmail(email, password);
    return userCredential?.user?.uid;
  }
}
