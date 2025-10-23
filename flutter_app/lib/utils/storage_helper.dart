import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

/// Storage Helper for local data persistence
class StorageHelper {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'user_data';

  static const _secureStorage = FlutterSecureStorage();

  /// Save authentication token securely
  static Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  /// Get authentication token
  static Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  /// Delete authentication token
  static Future<void> deleteToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  /// Save user data
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = json.encode(user.toJson());
    await prefs.setString(_keyUser, userJson);
  }

  /// Get user data
  static Future<User?> getUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyUser);
      
      if (userJson != null) {
        final userData = json.decode(userJson) as Map<String, dynamic>;
        return User.fromJson(userData);
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Delete user data
  static Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  /// Clear all stored data
  static Future<void> clearAll() async {
    await deleteToken();
    await deleteUser();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Save a string value
  static Future<void> saveString(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  /// Get a string value
  static Future<String?> getString(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  /// Save a boolean value
  static Future<void> saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  /// Get a boolean value
  static Future<bool?> getBool(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key);
  }
}

