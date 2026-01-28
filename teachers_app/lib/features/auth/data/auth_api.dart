import 'package:supabase_flutter/supabase_flutter.dart';

/// Authentication API service using Supabase
class AuthApi {
  final _supabase = Supabase.instance.client;

  /// Get current user
  User? get currentUser => _supabase.auth.currentUser;

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Attempts to log in with the provided credentials
  /// Returns a [Map] with user data on success, throws [AppAuthException] on failure
  Future<Map<String, dynamic>> login(String email, String password) async {
    // Validate credentials
    if (email.isEmpty || password.isEmpty) {
      throw AppAuthException('Email and password are required');
    }

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw AppAuthException('Login failed: No user returned');
      }

      return {
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['name'],
        'createdAt': user.createdAt,
      };
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      throw AppAuthException('An unexpected error occurred: $e');
    }
  }

  /// Attempts to create a new user account
  /// Returns a [Map] with user data on success, throws [AppAuthException] on failure
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    // Validate input
    if (email.isEmpty) {
      throw AppAuthException('Email is required');
    }
    if (password.isEmpty) {
      throw AppAuthException('Password is required');
    }
    if (name.isEmpty) {
      throw AppAuthException('Name is required');
    }
    if (password.length < 6) {
      throw AppAuthException('Password must be at least 6 characters');
    }

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      final user = response.user;
      if (user == null) {
        throw AppAuthException('Signup failed: No user returned');
      }

      return {
        'id': user.id,
        'email': user.email,
        'name': user.userMetadata?['name'],
        'createdAt': user.createdAt,
      };
    } on AuthException catch (e) {
      throw AppAuthException(e.message);
    } catch (e) {
      throw AppAuthException('An unexpected error occurred: $e');
    }
  }

  /// Signs out the current user
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      throw AppAuthException('Sign out failed: $e');
    }
  }
}

/// Custom exception for authentication errors
class AppAuthException implements Exception {
  final String message;

  AppAuthException(this.message);

  @override
  String toString() => message;
}
