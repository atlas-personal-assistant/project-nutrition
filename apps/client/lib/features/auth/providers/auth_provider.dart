import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/api_auth_service.dart';
import '../models/auth_models.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState {
  final User? user;
  final AuthStatus status;
  final String? error;

  const AuthState({
    this.user,
    this.status = AuthStatus.initial,
    this.error,
  });

  bool get isLoading => status == AuthStatus.loading;
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
}

class AuthNotifier extends ChangeNotifier {
  AuthState _state = const AuthState(status: AuthStatus.initial);
  
  AuthState get state => _state;
  
  AuthNotifier() {
    checkAuthStatus();
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setState(const AuthState(status: AuthStatus.loading));
    
    try {
      final userData = await ApiAuthService.registerUser(
        email: email.trim(),
        password: password,
        displayName: displayName.trim(),
      );

      if (userData.isNotEmpty) {
        final user = _createUserFromData(userData);
        _setState(AuthState(user: user, status: AuthStatus.authenticated));
      } else {
        _setState(const AuthState(
          status: AuthStatus.unauthenticated,
          error: 'Registrierung fehlgeschlagen',
        ));
      }
    } catch (e) {
      _setState(AuthState(
        status: AuthStatus.unauthenticated,
        error: 'Registrierung fehlgeschlagen: $e',
      ));
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setState(const AuthState(status: AuthStatus.loading));
    
    try {
      final userData = await ApiAuthService.loginUser(
        email: email.trim(),
        password: password,
      );

      final user = _createUserFromData(userData);
      _setState(AuthState(user: user, status: AuthStatus.authenticated));
    } catch (e) {
      _setState(const AuthState(
        status: AuthStatus.unauthenticated,
        error: 'E-Mail oder Passwort falsch',
      ));
    }
  }

  Future<void> logout() async {
    await ApiAuthService.logout();
    _setState(const AuthState(status: AuthStatus.unauthenticated));
  }

  Future<void> checkAuthStatus() async {
    final userData = await ApiAuthService.getCurrentUser();
    if (userData != null) {
      final user = _createUserFromData(userData);
      _setState(AuthState(user: user, status: AuthStatus.authenticated));
    } else {
      _setState(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  User _createUserFromData(Map<String, dynamic> data) {
    return User(
      id: data['id']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      displayName: data['username']?.toString() ?? '',
      status: 'active',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> clearAllData() async {
    await ApiAuthService.clearAll();
    _setState(const AuthState(status: AuthStatus.unauthenticated));
  }
}

final authProvider = ChangeNotifierProvider<AuthNotifier>((ref) {
  return AuthNotifier();
});
