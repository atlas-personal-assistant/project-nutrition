import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token';

  /// JWT Access Token speichern
  static Future<void> setToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// JWT Access Token lesen
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// JWT Access Token löschen
  static Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Refresh Token speichern
  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  /// Refresh Token lesen
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  /// Refresh Token löschen
  static Future<void> clearRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  /// Alle Tokens löschen (Logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
