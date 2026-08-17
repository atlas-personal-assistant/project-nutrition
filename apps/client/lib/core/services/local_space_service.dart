import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class LocalSpaceService {
  static const String _spacesKey = 'nutrition_spaces';

  static Future<List<Map<String, dynamic>>> _getSpaces() async {
    final prefs = await SharedPreferences.getInstance();
    final spacesJson = prefs.getString(_spacesKey);
    if (spacesJson == null || spacesJson.isEmpty) {
      return [];
    }
    try {
      return List<Map<String, dynamic>>.from(jsonDecode(spacesJson));
    } catch (e) {
      print('Error decoding spaces: $e');
      return [];
    }
  }

  static Future<void> _saveSpaces(List<Map<String, dynamic>> spaces) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_spacesKey, jsonEncode(spaces));
  }

  static String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }

  static Future<Map<String, dynamic>> createSpace({
    required String name,
  }) async {
    final spaces = await _getSpaces();
    
    final now = DateTime.now().toIso8601String();
    final spaceId = DateTime.now().millisecondsSinceEpoch.toString();
    
    final newSpace = {
      'id': spaceId,
      'name': name,
      'invite_code': _generateInviteCode(),
      'created_at': now,
      'updated_at': now,
    };

    spaces.add(newSpace);
    await _saveSpaces(spaces);
    
    return newSpace;
  }

  static Future<List<Map<String, dynamic>>> getSpaces() async {
    return await _getSpaces();
  }

  static Future<Map<String, dynamic>> joinSpace({
    required String inviteCode,
  }) async {
    final spaces = await _getSpaces();
    
    final space = spaces.firstWhere(
      (s) => s['invite_code'] == inviteCode,
      orElse: () => {},
    );
    
    if (space.isEmpty) {
      throw Exception('Ungültiger Einladungscode');
    }
    
    return Map<String, dynamic>.from(space);
  }

  // Debug: Lösche alle Spaces
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_spacesKey);
  }
}