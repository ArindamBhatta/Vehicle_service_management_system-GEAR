import 'package:learn_riverpod/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  // get current user
  User? get currentUser => _client.auth.currentUser;

  // emits updates whenever the authentication state changes
  Stream<User?> get authStateChanges => _client.auth.onAuthStateChange
      .map((AuthState event) {
        AppLogger.logger.d(
          'Raw Auth event: ${event.event}, Session: ${event.session != null}, User: ${event.session?.user.id}',
        );
        return event.session?.user;
      })
      .handleError((error, stackTrace) {
        AppLogger.logger.e(
          'Auth state stream error',
          error: error,
          stackTrace: stackTrace,
        );
        return null;
      });

  bool get isAutancated => _client.auth.currentUser != null;

  Future<User?> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
      );
      // Check response.user first, as session might be null if email confirmation is required
      if (response.user == null) {
        AppLogger.logger.w(
          'Sign up attempt failed for $email - no user returned.',
        );
        throw 'Failed to create user account. Please try again.';
      }

      if (response.session == null && response.user != null) {
        // This is expected if email confirmation is required
        AppLogger.logger.i(
          'Sign up successful for $email. User created, awaiting email confirmation.',
        );
        throw 'Please check your email to confirm your account before signing in.';
      }

      AppLogger.logger.i('Sign up and auto-login successful for $email');
      return response.user;
    } catch (error) {
      AppLogger.logger.e('Error signing up for $email', error: error);

      if (error is AuthException) {
        throw 'Sign up failed: ${error.message}';
      }
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    try {
      AppLogger.logger.i('Signing in user: $email');
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user;
    } catch (e) {
      AppLogger.logger.e('Error signing in for $email', error: e);
    }
  }

  Future<void> signOut() async {
    try {
      final userId = currentUser?.id;
      AppLogger.logger.i('Signing out user: ${userId ?? 'Unknown'}');
      await _client.auth.signOut();
      AppLogger.logger.i(
        'Sign out successful for user: ${userId ?? 'Unknown'}',
      );
    } catch (error) {
      AppLogger.logger.e('Error signing out', error: error);
    }
  }
}

/* 
   Stream to listen to authentication state changes
   The map() function is used to transform the data inside a stream
   use .map() to convert each AuthState object into a User? object.
Your app automatically reacts to:

A user logging in.

A user logging out.

A session expiring or being refreshed (token rotation).

A user being invalidated by the backend.

All of these trigger new events in the stream.
Without a stream, you'd have to manually call a function every time something happens — not reliable or scalable.
If you're using something like Supabase or Firebase, auth state can change without the user pressing a button, for example:

Session expires in background.

Password reset from another device.

Email verified.

Auth revoked remotely by admin.

A stream keeps your app in sync with reality.

StreamBuilder<User?>(
  stream: authStateChanges,
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return SplashScreen();
    }
    final user = snapshot.data;
    if (user == null) {
      return SignInScreen();
    } else {
      return HomeScreen();
    }
  },
);
*/
