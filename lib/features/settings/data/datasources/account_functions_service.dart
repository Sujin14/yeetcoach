import 'package:cloud_functions/cloud_functions.dart';

class AccountFunctionsService {
  /// deleteAccount is deployed here; a callable invoked in the wrong region fails with NOT_FOUND.
  static const _functionsRegion = 'us-central1';
  static const _deleteAccountFunction = 'deleteAccount';

  final FirebaseFunctions _functions;

  AccountFunctionsService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: _functionsRegion);

  /// Throws [FirebaseFunctionsException] on failure.
  Future<void> deleteAccount() async {
    await _functions
        .httpsCallable(
          _deleteAccountFunction,
          // Matches the function's 300s timeout; it deletes chats, calls and relationships.
          options: HttpsCallableOptions(timeout: const Duration(minutes: 5)),
        )
        .call<Map<String, dynamic>>();
  }
}
