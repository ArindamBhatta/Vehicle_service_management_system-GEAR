import 'package:learn_riverpod/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

//track every action in the app
class AuditService {
  final SupabaseClient _supabaseClient;
  static const String _tableName = 'audit_logs';

  AuditService(this._supabaseClient);

  /// Logs a chat project query audit log
  Future<void> logProjectQuery({
    required String userId,
    String? queryText,
    String? queryType,
    int? resultCount,
    String? errorMessage,
  }) async {
    try {
      final timeStamp = DateTime.now().toUtc();

      await _supabaseClient.from(_tableName).insert({
        'user_id': userId,
        'timestamp': timeStamp.toIso8601String(),
        'resource_type': 'chat',
        'action': 'query',
        'query-text': queryText,
        'query-type': queryType,
        'result_count': resultCount,
        'error_message': errorMessage,
      });
      AppLogger.logger.i('Audit log stored successfully: Project query');
    } catch (error) {
      AppLogger.logger.e('Failed to store audit log: $error');
    }
  }

  // logs the rate limit of audit logs

  Future<void> logRateLimit({
    required String userId,
    required String resourceType,
    required int requestCount,
    required int limit,
    required String window,
  }) async {
    try {
      final timeStamp = DateTime.now().toUtc();

      await _supabaseClient.from(_tableName).insert({
        'user_id': userId,
        'timestamp': timeStamp.toIso8601String(),
        'resource_type': resourceType,
        'action': 'rate_limit',
        'request_count': requestCount,
        'limit': limit,
        'window': window,
      });

      AppLogger.logger.i('Audit log stored successfully: Rate limit');
    } catch (error) {
      AppLogger.logger.e('Failed to store rate limit audit log: $error');
    }
  }
}
