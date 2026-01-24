/// Dummy authentication API service
/// This can be easily replaced with Firebase Authentication later
class AuthApi {
  // Simulated delay to mimic network request
  static const _networkDelay = Duration(milliseconds: 800);

  // Dummy user data for testing
  static const _dummyUser = {
    'email': 'test@minty.com',
    'password': 'password123',
    'name': 'Test User',
  };

  /// Attempts to log in with the provided credentials
  /// Returns a [Map] with user data on success, throws [AuthException] on failure
  Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(_networkDelay);

    // Validate credentials
    if (email.isEmpty || password.isEmpty) {
      throw AuthException('Email and password are required');
    }

    // Check against dummy credentials
    if (email == _dummyUser['email'] && password == _dummyUser['password']) {
      return {
        'id': 'user_123',
        'email': email,
        'name': _dummyUser['name'],
        'createdAt': DateTime.now().toIso8601String(),
      };
    }

    throw AuthException('Invalid email or password');
  }

  /// Attempts to create a new user account
  /// Returns a [Map] with user data on success, throws [AuthException] on failure
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(_networkDelay);

    // Validate input
    if (email.isEmpty) {
      throw AuthException('Email is required');
    }
    if (password.isEmpty) {
      throw AuthException('Password is required');
    }
    if (name.isEmpty) {
      throw AuthException('Name is required');
    }
    if (password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    // Simulate email already in use check
    if (email == _dummyUser['email']) {
      throw AuthException('Email is already in use');
    }

    // Return mock user data for successful signup
    return {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'email': email,
      'name': name,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    // In a real implementation, this would clear tokens/session
  }
}

/// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;

  AuthException(this.message);

  @override
  String toString() => message;
}
