import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_riverpod/core/provider/auth_provider.dart';
import 'package:learn_riverpod/core/provider/user_provider.dart';
import 'package:learn_riverpod/core/service/restoration_service.dart';
import 'package:learn_riverpod/core/utils/logger.dart';

final restorationServiceProvider = Provider<RestorationService?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  // Watch the current AppUser provider to get the user ID
  final currentUserAsyncValue = ref.watch(currentUserProvider);

  return currentUserAsyncValue.when(
    data: (currentUser) {
      if (currentUser != null) {
        AppLogger.logger.d(
          "restorationServiceProvider: Creating RestorationService for user ${currentUser.id}",
        );
        return RestorationService(client, currentUser.id);
      } else {
        AppLogger.logger.d(
          "restorationServiceProvider: AppUser is null, returning null.",
        );
        return null;
      }
    },
    loading: () {
      AppLogger.logger.d(
        "restorationServiceProvider: AppUser is loading, returning null.",
      );
      return null;
    },
    error: (err, stack) {
      AppLogger.logger.e(
        "restorationServiceProvider: Error fetching AppUser: $err",
      );
      return null;
    },
  );
});

// Provider for user's restoration projects
final userProjectsProvider = FutureProvider<List<dynamic>>((ref) async {
  final restorationService = ref.watch(restorationServiceProvider);
  if (restorationService == null) {
    return [];
  }

  try {
    final projects = await restorationService.getUserProjects();
    return projects;
  } catch (e) {
    AppLogger.logger.e("Error fetching user projects", error: e);
    return [];
  }
});
