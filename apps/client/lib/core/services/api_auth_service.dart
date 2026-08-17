import 'dart:convert';
import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class ApiAuthService {
  static String? _token;
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.fullBaseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));
  
  static String get baseUrl => ApiConstants.fullBaseUrl;
  
  static void _setupInterceptors() {
    _dio.interceptors.clear();
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        print('API Error: ${error.message}');
        handler.next(error);
      },
    ));
  }
  
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    _token = await SecureStorage.getToken();
    _setupInterceptors();
    return _token;
  }
  
  static Future<void> setToken(String token) async {
    _token = token;
    await SecureStorage.setToken(token);
    _setupInterceptors();
  }
  
  static Future<void> clearToken() async {
    _token = null;
    await SecureStorage.clearToken();
  }

  static Future<Map<String, dynamic>> registerUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'username': displayName,
          'email': email,
          'password': password,
        },
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        await setToken(data['access_token']);
        return await getCurrentUser() ?? {};
      }
      throw Exception('Registrierung fehlgeschlagen');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['detail'] != null) {
        throw Exception(e.response?.data['detail']);
      }
      throw Exception('Registrierung fehlgeschlagen: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        options: Options(
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        ),
        data: 'username=$email&password=$password',
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        await setToken(data['access_token']);
        return await getCurrentUser() ?? {};
      }
      throw Exception('Login fehlgeschlagen');
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['detail'] != null) {
        throw Exception(e.response?.data['detail']);
      }
      throw Exception('Login fehlgeschlagen: ${e.message}');
    }
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;
    
    try {
      final response = await _dio.get('/api/auth/me');
      if (response.statusCode == 200) {
        return response.data;
      }
      return null;
    } on DioException catch (e) {
      print('Get user error: ${e.message}');
      return null;
    }
  }

  static Future<void> logout() async {
    await clearToken();
  }

  static Future<void> clearAll() async {
    await clearToken();
  }
  
  // Admin-Funktionen
  static Future<List<Map<String, dynamic>>> getAllUsers() async {
    await getToken();
    
    try {
      final response = await _dio.get('/api/admin/users');
      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(response.data);
      }
      throw Exception('Nicht autorisiert');
    } on DioException catch (e) {
      throw Exception('Fehler: ${e.message}');
    }
  }
  
  static Future<void> deleteUser(int userId) async {
    await getToken();
    
    try {
      final response = await _dio.delete('/api/admin/users/$userId');
      if (response.statusCode != 200) {
        throw Exception('Löschen fehlgeschlagen');
      }
    } on DioException catch (e) {
      throw Exception('Fehler: ${e.message}');
    }
  }
  
  static Future<void> changePassword(String oldPassword, String newPassword) async {
    await getToken();
    
    try {
      final response = await _dio.post(
        '/api/admin/change-password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
      
      if (response.statusCode != 200) {
        throw Exception('Passwortänderung fehlgeschlagen');
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['detail'] != null) {
        throw Exception(e.response?.data['detail']);
      }
      throw Exception('Passwortänderung fehlgeschlagen: ${e.message}');
    }
  }
}
