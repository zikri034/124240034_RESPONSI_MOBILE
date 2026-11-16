import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const String _keyUsername = 'logged_in_username';
  final SharedPreferences _prefs;

  SessionService(this._prefs);

  static Future<SessionService> init() async {
    final prefs = await SharedPreferences.getInstance();
    return SessionService(prefs);
  }

  Future<bool> saveUser(String username) async {
    return await _prefs.setString(_keyUsername, username);
  }

  String? getUser() {
    return _prefs.getString(_keyUsername);
  }

  bool isLoggedIn() {
    final user = getUser();
    return user != null && user.trim().isNotEmpty;
  }

  Future<bool> logout() async {
    return await _prefs.remove(_keyUsername);
  }
}

