import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _client;

  AuthService(this._client);

  //supabse default redriect url
  static const _redirectUrl = String.fromEnvironment(
    'SUPABASE_REDIRECT_URL',
    defaultValue: 'http://localhost:3000/#/shop-dashboard',
  );

  User? get currentUser => _client.auth.currentUser;

  // Stream to listen to authentication state changes
  Stream<User?> get authStateChanges =>
      _client.auth.onAuthStateChange.map((event) => event.session?.user);
}
