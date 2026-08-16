import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  
  final FlutterSecureStorage _storage;
  
  SecureStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();
  
  // Access Token
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
  
  Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }
  
  // Refresh Token
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }
  
  // Both tokens at once
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }
  
  // User ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }
  
  Future<void> setUserId(String userId) async {
    await _storage.write(key: _userIdKey, value: userId);
  }
  
  // Clear all data (logout)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
  
  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}