import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_riverpod/core/model/user_model.dart';
import 'package:learn_riverpod/core/provider/auth_provider.dart';
import 'package:learn_riverpod/core/service/user_service.dart';
import 'package:learn_riverpod/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return UserService(client);
});

// Provides the current authenticated Supabase user
final supabaseUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.asData?.value;
});

// Provides the application-specific user profile (AppUser)
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final supabaseUser = ref.watch(supabaseUserProvider);

  if (supabaseUser == null) {
    AppLogger.logger.e(
      "currentUserProvider: No Supabase user, returning null.",
    ); // Debug log
    return null;
  }
  AppLogger.logger.e(
    "currentUserProvider: Supabase user found: ${supabaseUser.id}",
  );
  // Read the UserService instance from its provider
  final userService = ref.read(userServiceProvider);
  // Use createUserProfileIfNotExists to handle both fetching and creation
  final appUser = await userService.createUserProfileIfNotExists(supabaseUser);
  AppLogger.logger.d(
    "currentUserProvider: Fetched/Created AppUser: ${appUser?.id}",
  );
  return appUser;
});
