class ApiConstants {
  // Environment-based API URL
  // TODO: Configure via environment variables or build flavors
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://187.124.23.28',
  );
  
  static const String apiVersion = '/api/v1';
  static const String fullBaseUrl = '$baseUrl$apiVersion';
  
  // Auth Endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  
  // User Endpoints
  static const String me = '/users/me';
  static const String profile = '/users/me/profile';
  
  // Space Endpoints
  static const String spaces = '/spaces';
  static const String joinSpace = '/spaces/join';
}