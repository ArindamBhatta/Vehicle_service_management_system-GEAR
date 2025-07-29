import 'package:learn_riverpod/core/model/user_model.dart';
import 'package:learn_riverpod/core/globals/user_role.dart';
import 'package:learn_riverpod/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  final SupabaseClient _client;

  UserService(this._client);

  /// Get the user profile from the database
  Future<AppUser?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();

      return AppUser.fromJson(response);
    } catch (e) {
      AppLogger.logger.e('Error getting user profile', error: e);
      return null;
    }
  }

  /// Create or update a user profile
  Future<AppUser?> upsertUserProfile(AppUser user) async {
    try {
      final userData = user.toJson();

      final response = await _client
          .from('user_profiles')
          .upsert(userData)
          .select()
          .single();

      return AppUser.fromJson(response);
    } catch (e) {
      AppLogger.logger.e('Error upserting user profile', error: e);
      return null;
    }
  }

  /// Create a user profile if it doesn't exist
  Future<AppUser?> createUserProfileIfNotExists(
    User supabaseUser, {
    UserRole? role,
  }) async {
    try {
      final AppUser? existingUser = await getUserProfile(supabaseUser.id);
      if (existingUser != null) return existingUser;

      // ✅ Extract metadata from Google Sign-In
      final Map<String, dynamic> userMetadata = supabaseUser.userMetadata ?? {};

      final fullName = userMetadata['full_name'] as String? ?? '';

      final profileImageUrl = userMetadata['avatar_url'] as String? ?? '';

      // ✅ Optional: Split full name into first and last names
      final nameParts = fullName.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : null;
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : null;

      final newUser = AppUser(
        id: supabaseUser.id,
        email: supabaseUser.email,
        role: role ?? UserRole.undefined,
        firstName: firstName,
        lastName: lastName,
        profileImageUrl: profileImageUrl,
        phone: null,
        createdAt: DateTime.now(),
        isActive: true,
        shopIds: [],
      );

      return await upsertUserProfile(newUser);
    } catch (e) {
      AppLogger.logger.e('Error creating user profile', error: e);
      return null;
    }
  }

  /// Update user role
  Future<AppUser?> updateUserRole(String userId, UserRole role) async {
    try {
      final AppUser? user = await getUserProfile(userId);
      if (user == null) return null;

      final updatedUser = user.copyWith(role: role);

      return await upsertUserProfile(updatedUser);
    } catch (e) {
      AppLogger.logger.e('Error updating user role', error: e);
      return null;
    }
  }

  /// Update the user's onboarding completion status
  Future<void> updateOnboardingStatus(String userId, bool isComplete) async {
    try {
      await _client
          .from('user_profiles')
          .update({'is_onboarding_complete': isComplete})
          .eq('id', userId);

      AppLogger.logger.i(
        'Updated onboarding status for user $userId to $isComplete',
      );
    } catch (e) {
      AppLogger.logger.e(
        'Error updating onboarding status for user $userId',
        error: e,
      );
      rethrow;
    }
  }
}
