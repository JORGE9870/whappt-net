import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

/// Grabación nativa (AAC en archivo temporal).
class VoiceChatController {
  VoiceChatController({
    required this.onRecorded,
    required this.onUiUpdate,
    required this.onError,
  });

  final void Function(Uint8List bytes, int durationSec, String mimeType) onRecorded;
  final VoidCallback onUiUpdate;
  final void Function(String message) onError;

  final AudioRecorder _rec = AudioRecorder();
  Timer? _ticker;
  String? _path;
  bool _recording = false;
  int _elapsed = 0;

  bool get isRecording => _recording;
  int get elapsedSec => _elapsed;

  Future<void> beginRecording() async {
    final mic = await Permission.microphone.request();
    if (!mic.isGranted) {
      onError('Permiso de micrófono denegado');
      return;
    }
    if (!await _rec.hasPermission()) {
      onError('No hay permiso para grabar audio');
      return;
    }
    final dir = await getTemporaryDirectory();
    _path = p.join(dir.path, 'whappsat_voice_${DateTime.now().millisecondsSinceEpoch}.m4a');
    _elapsed = 0;
    try {
      await _rec.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: _path!);
      _recording = true;
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        _elapsed++;
        onUiUpdate();
      });
      onUiUpdate();
    } catch (e) {
      onError('No se pudo iniciar la grabación: $e');
    }
  }

  Future<void> endRecording({required bool send}) async {
    if (!_recording) return;
    _recording = false;
    _ticker?.cancel();
    _ticker = null;
    onUiUpdate();
    String? path;
    try {
      path = await _rec.stop();
    } catch (_) {}
    path ??= _path;
    _path = null;
    if (!send) {
      if (path != null) {
        try {
          await File(path).delete();
        } catch (_) {}
      }
      return;
    }
    if (path == null) {
      onError('Grabación vacía o demasiado corta');
      return;
    }
    final file = File(path);
    if (!await file.exists()) {
      onError('Grabación vacía o demasiado corta');
      return;
    }
    final bytes = await file.readAsBytes();
    try {
      await file.delete();
    } catch (_) {}
    if (bytes.isEmpty) {
      onError('Grabación vacía o demasiado corta');
      return;
    }
    final dur = _elapsed.clamp(1, 359999);
    _elapsed = 0;
    onRecorded(bytes, dur, 'audio/aac');
  }

  void abortRecording() {
    unawaited(endRecording(send: false));
  }

  void dispose() {
    _ticker?.cancel();
    Future.microtask(() async {
      try {
        if (await _rec.isRecording()) {
          await _rec.stop();
        }
      } catch (_) {}
      await _rec.dispose();
    });
  }
}
