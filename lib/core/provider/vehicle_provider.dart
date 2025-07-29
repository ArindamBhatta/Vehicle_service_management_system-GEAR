import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_riverpod/core/model/dropdown_model.dart';
import 'package:learn_riverpod/core/provider/auth_provider.dart';
import 'package:learn_riverpod/core/provider/drop_down_provider.dart';
import 'package:learn_riverpod/core/provider/user_provider.dart';
import 'package:learn_riverpod/core/service/image_upload_service.dart';
import 'package:learn_riverpod/core/service/vehicle_service.dart';
import 'package:learn_riverpod/core/utils/logger.dart';

final vehicleServiceProvider = Provider<VehicleService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final imageUploadService = ref.watch(imageUploadServiceProvider);
  // Watch the current AppUser provider to get the user ID
  final currentUserAsyncValue = ref.watch(currentUserProvider);

  return currentUserAsyncValue.when(
    data: (currentUser) {
      if (currentUser != null) {
        AppLogger.logger.d(
          "vehicleServiceProvider: Creating VehicleService for user ${currentUser.id}",
        ); // Debug log
        return VehicleService(client, currentUser.id, imageUploadService);
      } else {
        AppLogger.logger.d(
          "vehicleServiceProvider: AppUser is null, returning null.",
        ); // Debug log
        return null; // Return null if AppUser data is null
      }
    },
    loading: () {
      AppLogger.logger.d(
        "vehicleServiceProvider: AppUser is loading, returning null.",
      ); // Debug log
      return null; // Return null while AppUser is loading
    },
    error: (err, stack) {
      AppLogger.logger.e(
        "vehicleServiceProvider: Error fetching AppUser: $err",
      ); // Debug log
      return null; // Return null if there was an error fetching AppUser
    },
  );
});

// Provides a list of vehicle makes for dropdowns
final vehicleMakesProvider = FutureProvider<List<DropdownOption>>((ref) async {
  final dropdownService = ref.watch(dropdownServiceProvider);
  try {
    return await dropdownService.getOptions('vehicle_make');
  } catch (e) {
    AppLogger.logger.e("Error fetching vehicle make options", error: e);
    return [];
  }
});
