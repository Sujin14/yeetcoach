import '../../domain/repositories/auth_repository.dart';

class SignUpWithEmail {
  final AuthRepository repository;

  SignUpWithEmail(this.repository);

  /// Returns the new account's uid, or null if sign-up failed.
  Future<String?> call(String email, String password, String name) async {
    final userCredential = await repository.signUpWithEmail(
      email,
      password,
      name,
    );
    return userCredential?.user?.uid;
  }
}
