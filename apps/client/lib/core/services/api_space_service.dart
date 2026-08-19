import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import 'api_auth_service.dart';

class ApiSpaceService {
  static String get baseUrl => ApiConstants.fullBaseUrl;

  static Future<Map<String, dynamic>> createSpace({required String name, String description = ''}) async {
    final token = await ApiAuthService.getToken();
    
    final response = await http.post(
      Uri.parse('$baseUrl/spaces/create'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Space erstellen fehlgeschlagen');
    }
  }

  static Future<Map<String, dynamic>> joinSpace({required String inviteCode}) async {
    final token = await ApiAuthService.getToken();
    
    final response = await http.post(
      Uri.parse('$baseUrl/spaces/join'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'invite_code': inviteCode,
      }),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['detail'] ?? 'Space beitreten fehlgeschlagen');
    }
  }

  static Future<List<Map<String, dynamic>>> getSpaces() async {
    final token = await ApiAuthService.getToken();
    
    final response = await http.get(
      Uri.parse('$baseUrl/spaces/list'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Spaces laden fehlgeschlagen');
    }
  }
}
