import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hms_app/config/supabase_config.dart';
import 'package:hms_app/models/user.dart' as app;

class AuthRepository {
  final _client = SupabaseConfig.client;

  GoTrueClient get _auth => _client.auth;

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.session == null) {
        throw const AuthException('Authentication failed');
      }
      
      return response;
    } on AuthException {
      rethrow; 
    } catch (e) {
      throw AuthException('Authentication failed: ${e.toString()}');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Get current auth session
  Session? get currentSession => _auth.currentSession;

  /// Get current auth user
  User? get currentAuthUser => _auth.currentUser;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _auth.onAuthStateChange;

  /// Get app user from database matching auth user email
  Future<app.User?> getAppUser(String email) async {
    final response = await _client
        .from('users')
        .select()
        .eq('email', email)
        .maybeSingle();

    if (response == null) return null;
    return app.User.fromJson(response);
  }

  /// Get app user by ID
  Future<app.User?> getAppUserById(int id) async {
    final response = await _client
        .from('users')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return app.User.fromJson(response);
  }

  /// Refresh the current session
  Future<AuthResponse> refreshSession() async {
    return await _auth.refreshSession();
  }
}
