import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/services.dart';

/// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final bool isInitialized;
  final bool isAuthenticated;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.isInitialized = false,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    bool? isInitialized,
    bool? isAuthenticated,
    String? error,
    bool clearError = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Auth State Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final AdminService _adminService;

  AuthNotifier(this._authService, this._adminService) : super(AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    try {
      state = state.copyWith(isLoading: true);

      final isAuth = await _authService.isAuthenticated();
      if (isAuth) {
        final result = await _authService.getProfile();
        if (result.isSuccess && result.user != null) {
          state = state.copyWith(
            user: result.user,
            isAuthenticated: true,
            isLoading: false,
            isInitialized: true,
          );
          return;
        }
        // Token exists but profile fetch failed — token may be expired
        // Clear invalid tokens
        await _authService.logout();
      }

      state = state.copyWith(isLoading: false, isInitialized: true);
    } catch (e) {
      // Don't crash on startup — just mark as initialized with no auth
      state = state.copyWith(isLoading: false, isInitialized: true);
    }
  }

  /// Login
  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authService.login(email: email, password: password);

      if (result.isSuccess) {
        state = state.copyWith(
          user: result.user,
          isAuthenticated: true,
          isLoading: false,
          isInitialized: true,
        );
        return true;
      }

      state = state.copyWith(error: result.message, isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: 'Connection failed. Please check your network.',
        isLoading: false,
      );
      return false;
    }
  }

  /// Register
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
    required String role,
    String? address,
    String? nationality,
    String? bio,
    List<String>? languages,
    String? specialization,
    int? experience,
    double? dailyRate,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authService.register(
        email: email,
        password: password,
        fullName: fullName,
        phone: phone,
        role: role,
        address: address,
        nationality: nationality,
        bio: bio,
        languages: languages,
        specialization: specialization,
        experience: experience,
        dailyRate: dailyRate,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          user: result.user,
          isAuthenticated: true,
          isLoading: false,
          isInitialized: true,
        );
        return true;
      }

      state = state.copyWith(error: result.message, isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: 'Connection failed. Please check your network.',
        isLoading: false,
      );
      return false;
    }
  }

  /// Admin login (separate /admin/login endpoint + admin role)
  Future<bool> adminLogin({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _adminService.adminLogin(
        email: email,
        password: password,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          user: result.user,
          isAuthenticated: true,
          isLoading: false,
          isInitialized: true,
        );
        return true;
      }

      state = state.copyWith(error: result.message, isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        error: 'Connection failed. Please check your network.',
        isLoading: false,
      );
      return false;
    }
  }

  /// Forgot Password
  Future<bool> forgotPassword({required String email}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authService.forgotPassword(email: email);

      state = state.copyWith(isLoading: false);

      return result.isSuccess;
    } catch (e) {
      state = state.copyWith(
        error: 'Connection failed. Please check your network.',
        isLoading: false,
      );
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authService.logout();
    state = AuthState(isInitialized: true);
  }

  /// Update Profile
  Future<bool> updateProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _authService.updateProfile(data);

      if (result.isSuccess && result.user != null) {
        state = state.copyWith(user: result.user, isLoading: false);
        return true;
      }

      state = state.copyWith(error: result.message, isLoading: false);
      return false;
    } catch (e) {
      state = state.copyWith(error: 'Connection failed.', isLoading: false);
      return false;
    }
  }

  /// Clear any error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthNotifier(AuthService(apiClient), AdminService(apiClient));
});

/// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

/// Current User Provider
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

/// Is Admin Provider
final isAdminProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role == UserRole.admin;
});

/// Is Hotel Manager Provider
final isHotelManagerProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role == UserRole.hotelManager;
});

/// Is Guide Provider
final isGuideProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role == UserRole.guide;
});

/// Is Tourist Provider
final isTouristProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.role == UserRole.tourist;
});
