import 'package:cloud_functions/cloud_functions.dart';
import 'package:yeetcoach/core/utils/log_debug.dart';
import 'call_exception.dart';

/// Fetches the Metered API key from the getCallConfig Cloud Function.
/// The key lives in memory only; it is never bundled or persisted.
class MeteredConfigService {
  static const _configFunction = 'getCallConfig';

  /// getCallConfig is deployed here; a callable invoked in the wrong region fails with NOT_FOUND.
  static const _functionsRegion = 'us-central1';

  final FirebaseFunctions _functions;

  /// Shared across instances so the key is fetched once per app session.
  static String? _apiKey;

  MeteredConfigService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instanceFor(region: _functionsRegion);

  Future<String> getApiKey() async {
    final cached = _apiKey;
    if (cached != null) return cached;
    try {
      final result = await _functions.httpsCallable(_configFunction).call<Map<String, dynamic>>();
      final apiKey = result.data['apiKey'] as String?;
      if (apiKey == null || apiKey.isEmpty) {
        throw const CallException('Calling is not configured yet.');
      }
      return _apiKey = apiKey;
    } on FirebaseFunctionsException catch (e) {
      logDebug('MeteredConfigService: getCallConfig failed: ${e.code} — ${e.message}');
      throw CallException(
        e.code == 'unauthenticated'
            ? 'Please log in again to make calls.'
            : 'Calling is unavailable right now. Please try again.',
      );
    }
  }
}
