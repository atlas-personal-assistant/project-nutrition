import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalAuthService {
  static const String _usersKey = 'nutrition_users';
  static const String _currentUserKey = 'nutrition_current_user';

  static Future<Map<String, dynamic>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null || usersJson.isEmpty) {
      return {};
    }
    try {
      return Map<String, dynamic>.from(jsonDecode(usersJson));
    } catch (e) {
      print('Error decoding users: $e');
      return {};
    }
  }

  static Future<void> _saveUsers(Map<String, dynamic> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  static Future<void> registerUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final users = await _getUsers();
    
    if (users.containsKey(email)) {
      throw Exception('Ein Account mit dieser E-Mail existiert bereits');
    }

    final now = DateTime.now().toIso8601String();
    final userId = DateTime.now().millisecondsSinceEpoch.toString();
    
    users[email] = {
      'id': userId,
      'email': email,
      'password': password, // In production: hash this!
      'display_name': displayName,
      'status': 'active',
      'created_at': now,
      'updated_at': now,
    };

    await _saveUsers(users);
    await _setCurrentUser(users[email]!);
  }

  static Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    final users = await _getUsers();
    final userData = users[email];
    
    if (userData == null) {
      throw Exception('E-Mail oder Passwort falsch');
    }

    if (userData['password'] != password) {
      throw Exception('E-Mail oder Passwort falsch');
    }

    await _setCurrentUser(userData);
    return Map<String, dynamic>.from(userData);
  }

  static Future<void> _setCurrentUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentUserKey, jsonEncode(user));
  }

  static Future<Map<String, dynamic>?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_currentUserKey);
    if (userJson == null || userJson.isEmpty) return null;
    try {
      return jsonDecode(userJson);
    } catch (e) {
      return null;
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }

  // Debug: Lösche alle Daten
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usersKey);
    await prefs.remove(_currentUserKey);
  }
}
