import 'package:flutter_riverpod/flutter_riverpod.dart';
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

  AuthNotifier(this._authApi) : super(const AuthState());

  /// Attempts to log in with email and password
  Future<bool> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      final user = await _authApi.login(email, password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } on AuthException catch (e) {
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
    } on AuthException catch (e) {
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
