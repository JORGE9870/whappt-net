import 'dart:convert';
import 'dart:typed_data';

import 'dart:html' as html;

import '../models/chat_message.dart';
import 'chat_keys.dart';

String _msgsKey(String chatName) => 'whappsat_v${kChatStorageVersion}_msgs_${chatMsgsFileId(chatName)}';

String _photoKey(String chatName) => 'whappsat_v${kChatStorageVersion}_photo_${chatMsgsFileId(chatName)}';

/// Persistencia web (localStorage del navegador).
class ChatLocalStorage {
  ChatLocalStorage._();

  static Future<List<ChatMsg>?> loadMessages(String chatName) async {
    final raw = html.window.localStorage[_msgsKey(chatName)];
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final list = map['msgs'] as List<dynamic>?;
      if (list == null) return null;
      return list.map((e) => ChatMsg.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveMessages(String chatName, List<ChatMsg> msgs) async {
    final payload = jsonEncode({
      'v': int.parse(kChatStorageVersion),
      'msgs': msgs.map((m) => m.toJson()).toList(),
    });
    html.window.localStorage[_msgsKey(chatName)] = payload;
  }

  static Future<Uint8List?> loadContactPhoto(String chatName) async {
    final raw = html.window.localStorage[_photoKey(chatName)];
    return decodeOptionalB64(raw);
  }

  static Future<void> saveContactPhoto(String chatName, Uint8List? bytes) async {
    final k = _photoKey(chatName);
    if (bytes == null || bytes.isEmpty) {
      html.window.localStorage.removeItem(k);
    } else {
      html.window.localStorage[k] = base64Encode(bytes);
    }
  }
}
