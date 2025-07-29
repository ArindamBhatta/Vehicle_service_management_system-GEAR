import 'package:learn_riverpod/core/model/restoration_project_model.dart';
import 'package:learn_riverpod/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RestorationService {
  final SupabaseClient _client;
  final String _userId;

  RestorationService(this._client, this._userId);

  // Getter for userId to use in audit logs
  String get userId => _userId;

  // Getter for client to allow direct queries
  SupabaseClient get client => _client;

  // Table name for restoration projects
  static const String _tableName = 'restoration_projects';

  /// Get all restoration projects belonging to the current user
  Future<List<RestorationProject>> getUserProjects() async {
    try {
      AppLogger.logger.d('Fetching user projects', error: {'userId': _userId});

      final response = await _client
          .from(_tableName)
          .select('*, vehicles(*)')
          .eq('owner_id', _userId)
          .order('created_at', ascending: false);

      AppLogger.logger.d(
        'Fetched ${response.length} restoration projects',
        error: {'userId': _userId},
      );

      return response.map((data) => RestorationProject.fromJson(data)).toList();
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        'Error fetching user projects',
        error: {'error': e.toString(), 'userId': _userId},
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Get restoration projects for a specific shop
  Future<List<RestorationProject>> getShopProjects(String shopId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('*, vehicles(*)')
          .eq('shop_id', shopId)
          .order('created_at', ascending: false);

      return response.map((data) => RestorationProject.fromJson(data)).toList();
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        'Error fetching shop projects',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Get a single project by ID
  Future<RestorationProject?> getProjectById(String projectId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select('*, vehicles(*)')
          .eq('id', projectId)
          .maybeSingle();

      if (response == null) return null;

      return RestorationProject.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        'Error fetching project by ID',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Search projects by name or description
  Future<List<RestorationProject>> searchProjects(String query) async {
    try {
      // Only search for projects that belong to the current user
      final response = await _client
          .from(_tableName)
          .select('*, vehicles(*)')
          .eq('owner_id', _userId)
          .or('name.ilike.%$query%, description.ilike.%$query%')
          .order('created_at', ascending: false);

      return response.map((data) => RestorationProject.fromJson(data)).toList();
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        'Error searching projects',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  /// Create a basic project
  Future<String?> createBasicProject({
    required String title,
    required String vehicleId,
    String? shopId,
    String? description,
    double? budget,
  }) async {
    try {
      AppLogger.logger.d(
        'Creating basic project',
        error: {'title': title, 'vehicleId': vehicleId, 'userId': _userId},
      );

      final data = {
        'title': title,
        'vehicle_id': vehicleId,
        'owner_id': _userId,
        'shop_id': shopId,
        'description': description,
        'estimated_cost': budget,
        'status': 'pending', // Legacy status field
        'status_code': 'draft', // New status code
        'phase_code': 'planning', // Initial phase
        'setup_progress_code':
            'vehicle_selected', // Start with vehicle selection status
      };

      AppLogger.logger.d('Project data for insert: $data');

      // Use maybeSingle() to be more resilient if SELECT fails after INSERT due to RLS etc.
      final response = await _client
          .from(_tableName)
          .insert(data)
          .select('id')
          .maybeSingle(); // Changed from single() to maybeSingle()

      // Check if response is null or doesn't contain the ID
      if (response == null || response['id'] == null) {
        // This suggests the insert might have happened but returning the ID failed.
        // Or the insert itself failed in a way that didn't throw an exception caught below.
        AppLogger.logger.w(
          'Insert executed but failed to retrieve project ID from response.',
          error: {'response': response},
        );
        // Consider alternative ways to get ID if needed, e.g., query by other fields.
        // For now, returning null indicates failure to the notifier.
        return null;
      }

      final projectId =
          response['id'] as String?; // Ensure cast as nullable String
      AppLogger.logger.d('Created project and retrieved ID: $projectId');

      return projectId;
    } catch (e, stackTrace) {
      // Catch potential errors from insert OR select/maybeSingle
      AppLogger.logger.e(
        'Error during project creation/ID retrieval',
        error: {'error': e.toString(), 'userId': _userId},
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Update project status
  Future<bool> updateProjectStatus(String projectId, String statusCode) async {
    try {
      AppLogger.logger.d(
        'Updating project status',
        error: {'projectId': projectId, 'statusCode': statusCode},
      );

      await _client
          .from(_tableName)
          .update({
            'status_code': statusCode,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', projectId);

      return true;
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        'Error updating project status',
        error: {'error': e.toString(), 'projectId': projectId},
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Update project phase
  Future<bool> updateProjectPhase(String projectId, String phaseCode) async {
    try {
      AppLogger.logger.d(
        'Updating project phase',
        error: {'projectId': projectId, 'phaseCode': phaseCode},
      );

      await _client
          .from(_tableName)
          .update({
            'phase_code': phaseCode,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', projectId);

      return true;
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        'Error updating project phase',
        error: {'error': e.toString(), 'projectId': projectId},
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Update setup progress
  Future<bool> updateSetupProgress(
    String projectId,
    String progressCode,
  ) async {
    try {
      AppLogger.logger.d(
        'Updating setup progress',
        error: {'projectId': projectId, 'progressCode': progressCode},
      );

      await _client
          .from(_tableName)
          .update({
            'setup_progress_code': progressCode,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', projectId);

      return true;
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        'Error updating setup progress',
        error: {'error': e.toString(), 'projectId': projectId},
        stackTrace: stackTrace,
      );
      return false;
    }
  }

  /// Update progress percentage
  Future<bool> updateProgressPercentage(
    String projectId,
    int percentage,
  ) async {
    try {
      if (percentage < 0 || percentage > 100) {
        throw ArgumentError('Percentage must be between 0 and 100');
      }

      AppLogger.logger.d(
        'Updating progress percentage',
        error: {'projectId': projectId, 'percentage': percentage},
      );

      await _client
          .from(_tableName)
          .update({
            'progress_percentage': percentage,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', projectId);

      return true;
    } catch (e, stackTrace) {
      AppLogger.logger.e(
        'Error updating progress percentage',
        error: {'error': e.toString(), 'projectId': projectId},
        stackTrace: stackTrace,
      );
      return false;
    }
  }
}
