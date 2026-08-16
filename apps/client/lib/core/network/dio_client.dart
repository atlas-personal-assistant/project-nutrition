import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

class DioClient {
  late final Dio _dio;
  final SecureStorage _secureStorage;
  
  DioClient({SecureStorage? secureStorage}) 
      : _secureStorage = secureStorage ?? SecureStorage();
  
  Dio get dio {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.fullBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
    return _dio;
  }
  
  void _setupInterceptors() {
    // Request interceptor - add auth token
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          print('REQUEST: ${options.method} ${options.path}');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print('RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          print('ERROR: ${error.response?.statusCode} ${error.requestOptions.path}');
          print('BODY: ${error.response?.data}');
        }
        
        // Handle 401 - try refresh token
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            // Retry original request with new token
            final token = await _secureStorage.getAccessToken();
            error.requestOptions.headers['Authorization'] = 'Bearer $token';
            return handler.resolve(await _dio.fetch(error.requestOptions));
          }
        }
        
        return handler.next(error);
      },
    ));
  }
  
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) return false;
      
      final response = await _dio.post(
        ApiConstants.refresh,
        data: {'refresh_token': refreshToken},
      );
      
      if (response.statusCode == 200) {
        await _secureStorage.setTokens(
          accessToken: response.data['access_token'],
          refreshToken: response.data['refresh_token'],
        );
        return true;
      }
    } catch (e) {
      if (kDebugMode) print('Refresh token failed: $e');
    }
    return false;
  }
}