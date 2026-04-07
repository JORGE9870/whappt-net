import 'dart:convert';

/// Versión de esquema de almacenamiento local.
const String kChatStorageVersion = '1';

/// Misma clave en web (localStorage) e IO (SharedPreferences).
const String kPhonePrefsKey = 'whappsat_v1_phone';

String chatMsgsFileId(String chatName) =>
    base64Url.encode(utf8.encode(chatName)).replaceAll('=', '');
