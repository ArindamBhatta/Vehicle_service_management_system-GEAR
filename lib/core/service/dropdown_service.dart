import 'package:learn_riverpod/core/model/dropdown_model.dart';
import 'package:learn_riverpod/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DropdownService {
  final SupabaseClient _client;

  // Constructor to inject SupabaseClient
  DropdownService(this._client);

  Future<List<DropdownOption>> getOptions(String category) async {
    try {
      AppLogger.logger.d('Fetching $category options from database');

      final response = await _client
          .from('dropdown_options')
          .select()
          .eq('category', category)
          .eq('is_active', true) // Only fetch active options
          .order('display_order', ascending: true);

      AppLogger.logger.d('$category options response: $response');

      if ((response.isEmpty)) {
        return [];
      }

      final options = (response as List).map((option) {
        // Ensure category is set correctly
        final Map<String, dynamic> optionWithCategory = {...option};
        if (!optionWithCategory.containsKey('category')) {
          optionWithCategory['category'] = category;
        }
        return DropdownOption.fromJson(optionWithCategory);
      }).toList();

      return options;
    } catch (e) {
      AppLogger.logger.e('Error fetching $category options', error: e);
      rethrow;
    }
  }

  Future<List<DropdownOption>> getAllOptions(String category) async {
    try {
      AppLogger.logger.d(
        'Fetching all $category options from database (including inactive)',
      );

      final response = await _client
          .from('dropdown_options')
          .select()
          .eq('category', category)
          .order('display_order', ascending: true);

      AppLogger.logger.d('All $category options response: $response');

      // Handle potential null or empty list
      if ((response.isEmpty)) {
        return [];
      }

      final options = (response as List).map((option) {
        // Ensure category is set correctly
        final Map<String, dynamic> optionWithCategory = {...option};
        if (!optionWithCategory.containsKey('category')) {
          optionWithCategory['category'] = category;
        }
        return DropdownOption.fromJson(optionWithCategory);
      }).toList();

      return options;
    } catch (e) {
      AppLogger.logger.e('Error fetching all $category options', error: e);
      rethrow;
    }
  }

  // Make method an instance method
  Future<List<DropdownOption>> getVehicleTypeOptions() async {
    return getOptions('vehicle_type');
  }

  // Method to set a dropdown option's active status
  Future<void> setOptionActiveStatus(
    String category,
    String value,
    bool isActive,
  ) async {
    try {
      AppLogger.logger.d(
        'Setting $category/$value active status to: $isActive',
      );

      await _client
          .from('dropdown_options')
          .update({'is_active': isActive})
          .eq('category', category)
          .eq('value', value);

      AppLogger.logger.d(
        'Successfully updated active status for $category/$value',
      );
    } catch (e) {
      AppLogger.logger.e(
        'Error updating active status for $category/$value',
        error: e,
      );
      rethrow;
    }
  }

  // Convenience method to add a new dropdown option
  Future<void> addOption({
    required String category,
    required String value,
    required String displayName,
    int displayOrder = 100,
    bool isActive = true,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      AppLogger.logger.d('Adding new dropdown option: $category/$value');

      await _client.from('dropdown_options').insert({
        'category': category,
        'value': value,
        'display_name': displayName,
        'display_order': displayOrder,
        'is_active': isActive,
        if (additionalData != null) 'additional_data': additionalData,
      });

      AppLogger.logger.d(
        'Successfully added new dropdown option: $category/$value',
      );
    } catch (e) {
      AppLogger.logger.e(
        'Error adding dropdown option: $category/$value',
        error: e,
      );
      rethrow;
    }
  }
}
