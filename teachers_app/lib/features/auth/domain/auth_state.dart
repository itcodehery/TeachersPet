import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../data/auth_api.dart';

/// Represents the current authentication state
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

/// Holds the authentication state data
class AuthState {
  final AuthStatus status;
  final Map<String, dynamic>? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    Map<String, dynamic>? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

/// StateNotifier for managing authentication state
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthApi _authApi;
  StreamSubscription<supabase.AuthState>? _authSubscription;

  AuthNotifier(this._authApi) : super(const AuthState()) {
    _init();
  }

  void _init() {
    final user = _authApi.currentUser;
    if (user != null) {
      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: _userToMap(user),
      );
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }

    _authSubscription = _authApi.authStateChanges.listen((data) {
      final event = data.event;
      final session = data.session;

      if (event == supabase.AuthChangeEvent.signedIn ||
          event == supabase.AuthChangeEvent.tokenRefreshed) {
        if (session != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: _userToMap(session.user),
          );
        }
      } else if (event == supabase.AuthChangeEvent.signedOut) {
        state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
      }
    });
  }

  Map<String, dynamic> _userToMap(supabase.User user) {
    return {
      'id': user.id,
      'email': user.email,
      'name': user.userMetadata?['name'],
      'createdAt': user.createdAt,
    };
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  /// Attempts to log in with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final user = await _authApi.login(email, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } on AppAuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Attempts to create a new account
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final user = await _authApi.signUp(
        email: email,
        password: password,
        name: name,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } on AppAuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _authApi.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// Sends a password reset email
  Future<bool> resetPassword(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      await _authApi.sendPasswordResetEmail(email);
      // We don't change status to specific 'resetSent' to avoid UI jumps,
      // but we could. For now, just set back to unauthenticated (or whatever it was)
      // Actually, loading->success is good to stop the spinner.
      // But we are likely on a separate page.
      // Let's just return true and not change the main user state (which is probably unauthenticated).
      // We set status back to unauthenticated if it was unauthenticated.
      // But since we might be on login page, let's just restore previous state or set to unauthenticated.
      // Easiest is to set status to unauthenticated (since user is likely not logged in)
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } on AppAuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Clears any error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for the auth API
final authApiProvider = Provider<AuthApi>((ref) => AuthApi());

/// Provider for auth state
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authApi = ref.watch(authApiProvider);
  return AuthNotifier(authApi);
});
