import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/chat_message.dart';
import 'chat_keys.dart';

/// Archivos en el almacenamiento privado de la app (GB de espacio disponible en el dispositivo).
class ChatLocalStorage {
  ChatLocalStorage._();

  static Future<Directory> _dir() async {
    final root = await getApplicationSupportDirectory();
    final d = Directory(p.join(root.path, 'whappsat_data'));
    if (!await d.exists()) await d.create(recursive: true);
    return d;
  }

  static Future<List<ChatMsg>?> loadMessages(String chatName) async {
    final id = chatMsgsFileId(chatName);
    final f = File(p.join((await _dir()).path, 'msgs_$id.json'));
    if (!await f.exists()) return null;
    try {
      final map = jsonDecode(await f.readAsString()) as Map<String, dynamic>;
      final list = map['msgs'] as List<dynamic>?;
      if (list == null) return null;
      return list.map((e) => ChatMsg.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return null;
    }
  }

  static Future<void> saveMessages(String chatName, List<ChatMsg> msgs) async {
    final id = chatMsgsFileId(chatName);
    final f = File(p.join((await _dir()).path, 'msgs_$id.json'));
    final payload = jsonEncode({
      'v': int.parse(kChatStorageVersion),
      'msgs': msgs.map((m) => m.toJson()).toList(),
    });
    await f.writeAsString(payload);
  }

  static Future<Uint8List?> loadContactPhoto(String chatName) async {
    final id = chatMsgsFileId(chatName);
    final f = File(p.join((await _dir()).path, 'photo_$id.bin'));
    if (!await f.exists()) return null;
    return f.readAsBytes();
  }

  static Future<void> saveContactPhoto(String chatName, Uint8List? bytes) async {
    final id = chatMsgsFileId(chatName);
    final f = File(p.join((await _dir()).path, 'photo_$id.bin'));
    if (bytes == null || bytes.isEmpty) {
      if (await f.exists()) await f.delete();
    } else {
      await f.writeAsBytes(bytes);
    }
  }
}
