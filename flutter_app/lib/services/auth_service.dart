import '../models/user.dart';
import '../config/api_config.dart';
import '../utils/storage_helper.dart';
import 'api_service.dart';

/// Authentication Service
class AuthService {
  final ApiService _apiService;

  AuthService({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  /// Register a new user
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String fullName,
    required UserType userType,
    String? phone,
    String? companyName,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        body: {
          'email': email,
          'password': password,
          'full_name': fullName,
          'user_type': userType.name,
          if (phone != null) 'phone': phone,
          if (companyName != null) 'company_name': companyName,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final authResponse = AuthResponse.fromJson(response['data'] as Map<String, dynamic>);
        
        // Save token
        await StorageHelper.saveToken(authResponse.token);
        await StorageHelper.saveUser(authResponse.user);

        return authResponse;
      } else {
        throw ApiException(response['message'] as String? ?? 'Registration failed');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Registration error: $e');
    }
  }

  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        body: {
          'email': email,
          'password': password,
        },
      );

      if (response['success'] == true && response['data'] != null) {
        final authResponse = AuthResponse.fromJson(response['data'] as Map<String, dynamic>);
        
        // Save token and user
        await StorageHelper.saveToken(authResponse.token);
        await StorageHelper.saveUser(authResponse.user);

        return authResponse;
      } else {
        throw ApiException(response['message'] as String? ?? 'Login failed');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Login error: $e');
    }
  }

  /// Get current user info
  Future<User> getCurrentUser() async {
    try {
      final response = await _apiService.get(
        ApiConfig.getMe,
        requiresAuth: true,
      );

      if (response['success'] == true && response['data'] != null) {
        final userData = response['data'] as Map<String, dynamic>;
        final user = User.fromJson(userData['user'] as Map<String, dynamic>);
        
        // Update stored user
        await StorageHelper.saveUser(user);

        return user;
      } else {
        throw ApiException(response['message'] as String? ?? 'Failed to get user info');
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Get user error: $e');
    }
  }

  /// Logout
  Future<void> logout() async {
    await StorageHelper.clearAll();
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await StorageHelper.getToken();
    return token != null;
  }

  /// Get stored user
  Future<User?> getStoredUser() async {
    return await StorageHelper.getUser();
  }

  void dispose() {
    _apiService.dispose();
  }
}

