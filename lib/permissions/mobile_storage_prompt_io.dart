import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kStoragePromptDone = 'whappsat_prompted_storage_v1';

Future<void> promptMobileStorageIfNeeded(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  if (prefs.getBool(_kStoragePromptDone) == true) return;
  if (!context.mounted) return;

  final allow = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1F2C34),
      title: const Text('Guardar en el dispositivo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      content: const Text(
        'WhappsAt guardará tus conversaciones y archivos en el almacenamiento privado de la app. '
        'Ahí puedes usar el espacio libre del teléfono (mucho más que en un navegador).\n\n'
        'Si aceptas, en Android también se solicitará el permiso de almacenamiento cuando el sistema lo permita, '
        'para exportar y compartir archivos.',
        style: TextStyle(color: Color(0xFF8696A0), height: 1.35),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Ahora no', style: TextStyle(color: Color(0xFF8696A0))),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF00A884), foregroundColor: Colors.black),
          child: const Text('Permitir', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );

  await prefs.setBool(_kStoragePromptDone, true);

  if (allow != true || !context.mounted) return;

  if (Platform.isAndroid) {
    await Permission.storage.request();
  }
}
