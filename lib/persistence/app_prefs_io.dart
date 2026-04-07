import 'package:shared_preferences/shared_preferences.dart';

import 'chat_keys.dart';

class AppPrefs {
  AppPrefs._();

  static Future<String?> loadPhone() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(kPhonePrefsKey);
    if (v == null || v.isEmpty) return null;
    return v;
  }

  static Future<void> savePhone(String phone) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(kPhonePrefsKey, phone);
  }
}
