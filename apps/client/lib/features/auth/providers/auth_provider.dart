import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../models/auth_models.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../../../core/constants/api_constants.dart';

// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final DioClient _dioClient;
  final SecureStorage _secureStorage;

  AuthNotifier({
    DioClient? dioClient,
    SecureStorage? secureStorage,
  })  : _dioClient = dioClient ?? DioClient(),
        _secureStorage = secureStorage ?? SecureStorage(),
        super(const AuthState());

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'display_name': displayName,
        },
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      
      await _secureStorage.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      await _secureStorage.setUserId(authResponse.user.id);
      
      state = state.copyWith(
        user: authResponse.user,
        isLoading: false,
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? 'Registration failed';
      state = state.copyWith(isLoading: false, error: errorMsg);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final response = await _dioClient.dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final authResponse = AuthResponse.fromJson(response.data);
      
      await _secureStorage.setTokens(
        accessToken: authResponse.accessToken,
        refreshToken: authResponse.refreshToken,
      );
      await _secureStorage.setUserId(authResponse.user.id);
      
      state = state.copyWith(
        user: authResponse.user,
        isLoading: false,
      );
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['detail'] ?? 'Login failed';
      state = state.copyWith(isLoading: false, error: errorMsg);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'An unexpected error occurred');
    }
  }

  Future<void> logout() async {
    await _secureStorage.clearAll();
    state = const AuthState();
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _secureStorage.isLoggedIn();
    if (!isLoggedIn) {
      state = const AuthState();
      return;
    }

    try {
      final response = await _dioClient.dio.get(ApiConstants.me);
      final user = User.fromJson(response.data);
      state = state.copyWith(user: user);
    } catch (e) {
      // Token invalid, clear storage
      await _secureStorage.clearAll();
      state = const AuthState();
    }
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});