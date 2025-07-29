// Provides the ShopService instance
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_riverpod/core/model/shop_model.dart';
import 'package:learn_riverpod/core/provider/auth_provider.dart';
import 'package:learn_riverpod/core/provider/role_provider.dart';
import 'package:learn_riverpod/core/provider/user_provider.dart';
import 'package:learn_riverpod/core/service/shop_service.dart';
import 'package:learn_riverpod/core/utils/logger.dart';

final shopServiceProvider = Provider<ShopService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ShopService(client);
});

// Provides the list of shops associated with the current user (based on role)
final userShopsProvider = FutureProvider<List<Shop>>((ref) async {
  final userRole = ref.watch(userRoleProvider);
  // Get the AppUser data directly from the provider's future
  final currentUser = await ref.watch(currentUserProvider.future);

  if (currentUser == null || userRole == null) {
    AppLogger.logger.d(
      "userShopsProvider: Current user or role is null, returning [].",
    );
    return [];
  }
  AppLogger.logger.d(
    "userShopsProvider: User ID: ${currentUser.id}, Role: $userRole",
  ); // Debug log

  // Read the ShopService instance from its provider
  final shopService = ref.read(shopServiceProvider);

  if (userRole.isShopOwner) {
    AppLogger.logger.d("userShopsProvider: Fetching shops for owner.");
    return await shopService.getShopsByOwnerId(currentUser.id);
  } else if (userRole.isShopEmployee ||
      userRole.isAppraiser ||
      userRole.isWhiteGloveOfficer) {
    AppLogger.logger.d(
      "userShopsProvider: Fetching shops for employee/appraiser/officer.",
    );
    return await shopService.getShopsByEmployeeId(currentUser.id);
  }

  AppLogger.logger.d(
    "userShopsProvider: User role doesn't match shop criteria, returning [].",
  );
  return [];
});
