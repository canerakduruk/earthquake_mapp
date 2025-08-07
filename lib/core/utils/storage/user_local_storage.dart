import 'package:shared_preferences/shared_preferences.dart';

class UserLocalStorage {
  static const _keyEmail = 'userEmail';
  static const _keyUid = 'userUid';

  // Kullanıcı bilgilerini kaydet
  static Future<void> saveUser({
    required String email,
    required String uid,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyUid, uid);
  }

  // Kullanıcı emailini al
  static Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyEmail);
  }

  // Kullanıcı uid'sini al
  static Future<String?> getUid() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUid);
  }

  // Kaydedilmiş kullanıcı bilgilerini temizle (logout vs için)
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyUid);
  }
}
