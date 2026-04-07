import 'dart:html' as html;

import 'chat_keys.dart';

class AppPrefs {
  AppPrefs._();

  static Future<String?> loadPhone() async {
    final v = html.window.localStorage[kPhonePrefsKey];
    if (v == null || v.isEmpty) return null;
    return v;
  }

  static Future<void> savePhone(String phone) async {
    html.window.localStorage[kPhonePrefsKey] = phone;
  }
}
