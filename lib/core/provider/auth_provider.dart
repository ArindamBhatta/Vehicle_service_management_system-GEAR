import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gear_app/core/service/auth_service.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// Step 1: Connect with Database read only
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

//step 3: handel authentication state changes login, logout, etc.
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

// After authenticate we provide a stream to listen user authentication state changes
final authStateChangesProvider = StreamProvider((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges; //stram of auth state changes
});

final splashButtonTappedProvider = StateProvider<bool>((ref) => false);

// Provides a boolean indicating if the user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(data: (user) => user != null, orElse: () => false);
});
