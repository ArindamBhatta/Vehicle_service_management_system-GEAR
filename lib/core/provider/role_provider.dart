// Provides the role of the current user
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_riverpod/core/globals/user_role.dart';
import 'package:learn_riverpod/core/provider/user_provider.dart';
import 'package:learn_riverpod/core/utils/logger.dart';

enum AppMode { carOwner, shopOwner }

final userRoleProvider = Provider<UserRole?>((ref) {
  final userAsyncValue = ref.watch(currentUserProvider);

  return userAsyncValue.when(
    data: (user) => user?.role,
    loading: () => null, // Return null while loading
    error: (err, stack) {
      AppLogger.logger.d("Error in userRoleProvider: $err");
      return null;
    },
  );
});

// App mode provider to control which mode the app is in
final appModeProvider = StateProvider<AppMode>((ref) => AppMode.carOwner);

// Feature flag providers - useful for app splitting
final isInShopAppProvider = Provider<bool>((ref) {
  final appMode = ref.watch(appModeProvider);
  return appMode == AppMode.shopOwner;
});

final canAccessCarOwnerFeaturesProvider = Provider<bool>((ref) {
  final userRole = ref.watch(userRoleProvider);
  return userRole != null && (userRole.isCarOwnerRelated || userRole.isAdmin);
});
