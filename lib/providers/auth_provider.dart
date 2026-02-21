import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hms_app/models/user.dart' as app;
import 'package:hms_app/repositories/auth_repository.dart';

final authRepositoryProvider = Provider((ref) => AuthRepository());

/// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final app.User? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    app.User? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }
}

/// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepo;
  StreamSubscription? _authSubscription;

  AuthNotifier(this._authRepo) : super(const AuthState(isLoading: true)) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Check existing session
    final session = _authRepo.currentSession;
    if (session != null) {
      final authUser = _authRepo.currentAuthUser;
      if (authUser?.email != null) {
        final appUser = await _authRepo.getAppUser(authUser!.email!);
        if (appUser != null) {
          state = AuthState(isAuthenticated: true, user: appUser);
        } else {
          state = const AuthState(isAuthenticated: false);
        }
      }
    } else {
      state = const AuthState(isAuthenticated: false);
    }

    // Listen to auth changes
    _authSubscription = _authRepo.authStateChanges.listen((event) async {
      if (state.isLoading) return;

      if (event.event == AuthChangeEvent.signedOut) {
        if (state.isAuthenticated) {
          state = const AuthState(isAuthenticated: false);
        }
      } else if (event.event == AuthChangeEvent.tokenRefreshed) {
        // Only handle token refresh if already authenticated
        if (state.isAuthenticated && event.session?.user.email != null) {
          final appUser = await _authRepo.getAppUser(
            event.session!.user!.email!,
          );
          if (appUser != null && appUser.isActive == true) {
            state = AuthState(isAuthenticated: true, user: appUser);
          } else {
            await _authRepo.signOut();
            state = const AuthState(isAuthenticated: false);
          }
        }
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // First validate credentials with Supabase
      final response = await _authRepo.signIn(email: email, password: password);

      // Check if authentication was successful
      if (response.session == null || response.user == null) {
        state = const AuthState(
          isAuthenticated: false,
          error: 'Invalid email or password',
        );
        return;
      }

      // Get app user from database
      final appUser = await _authRepo.getAppUser(email);
      if (appUser == null) {
        await _authRepo.signOut();
        state = const AuthState(
          isAuthenticated: false,
          error:
              'User account not found in the system. Contact your administrator.',
        );
        return;
      }

      if (appUser.isActive == false) {
        await _authRepo.signOut();
        state = const AuthState(
          isAuthenticated: false,
          error:
              'Your account has been deactivated. Contact your administrator.',
        );
        return;
      }

      // Success - set authenticated state
      state = AuthState(isAuthenticated: true, user: appUser);
    } on AuthException catch (e) {
      await _authRepo.signOut();
      state = AuthState(isAuthenticated: false, error: e.message);
    } catch (e) {
      await _authRepo.signOut();
      state = AuthState(
        isAuthenticated: false,
        error: 'An unexpected error occurred: ${e.toString()}',
      );
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
    state = const AuthState(isAuthenticated: false);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

final currentUserProvider = Provider<app.User?>((ref) {
  return ref.watch(authProvider).user;
});

final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(currentUserProvider)?.role;
});
