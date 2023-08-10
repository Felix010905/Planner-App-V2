import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  final String usernameKey = 'username';
  final String passwordKey = 'password';
  final SharedPreferences prefs;

  AuthStorage(this.prefs);

  String? getSavedUsername() {
    return prefs.getString(usernameKey);
  }

  String? getSavedPassword() {
    return prefs.getString(passwordKey);
  }

  Future<void> saveCredentials(String username, String password) async {
    await prefs.setString(usernameKey, username);
    await prefs.setString(passwordKey, password);
  }

  Future<void> clearCredentials() async {
    await prefs.remove(usernameKey);
    await prefs.remove(passwordKey);
  }
}
