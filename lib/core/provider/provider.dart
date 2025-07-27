import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_riverpod/core/service/audit_service.dart';
import 'package:learn_riverpod/core/service/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ------ CORE PROVIDER FILE ------

// Step 1: Connect with Database read only
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

//step 2:

final auditServiceProvider = Provider((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuditService(client);
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

// Provides a boolean indicating if the user is authenticated

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateChangesProvider);
  return authState.maybeWhen(data: (user) => user != null, orElse: () => false);
});
