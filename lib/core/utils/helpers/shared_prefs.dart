// lib/core/utils/helpers/shared_prefs.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_prefs.g.dart';

@riverpod
Future<SharedPrefsHelper> sharedPrefs(SharedPrefsRef ref) async {
  final helper = SharedPrefsHelper();
  await helper.init();
  return helper;
}

class SharedPrefsHelper {
  static const _tokenKey = 'auth_token';
  static const _sessionKey = 'session_id';
  static const _isLoggedInKey = 'is_logged_in';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token
  Future<String?> getToken() async => _prefs.getString(_tokenKey);
  Future<void> saveToken(String token) async =>
      _prefs.setString(_tokenKey, token);
  Future<void> clearToken() async => _prefs.remove(_tokenKey);

  // Session ID
  Future<String?> getSessionId() async => _prefs.getString(_sessionKey);
  Future<void> saveSessionId(String id) async =>
      _prefs.setString(_sessionKey, id);

  // Login state
  Future<bool> isLoggedIn() async => _prefs.getBool(_isLoggedInKey) ?? false;
  Future<void> setLoggedIn(bool value) async =>
      _prefs.setBool(_isLoggedInKey, value);

  // Clear all
  Future<void> clearAll() async {
    await _prefs.clear();
  }

  // Add these two methods if they don't exist:

  Future<void> saveRefreshToken(String refreshToken) async {
    await _prefs.setString('refresh_token', refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return _prefs.getString('refresh_token');
  }

  Future<void> clearAuth() async {
    await Future.wait([
      _prefs.remove('auth_token'),
      _prefs.remove('refresh_token'),
      _prefs.remove('session_id'),
    ]);
  }
}
