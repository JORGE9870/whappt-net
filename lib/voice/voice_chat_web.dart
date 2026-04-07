import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

/// Grabación de nota de voz en navegador (MediaRecorder).
class VoiceChatController {
  VoiceChatController({
    required this.onRecorded,
    required this.onUiUpdate,
    required this.onError,
  });

  final void Function(Uint8List bytes, int durationSec, String mimeType) onRecorded;
  final VoidCallback onUiUpdate;
  final void Function(String message) onError;

  bool _wantVoiceRecord = false;
  bool _isRecordingVoice = false;
  int _voiceRecordElapsedSec = 0;
  Timer? _voiceRecordTicker;
  html.MediaRecorder? _voiceMediaRecorder;
  html.MediaStream? _voiceMediaStream;
  final List<html.Blob> _voiceChunks = [];
  String _voiceMimeUsed = 'audio/webm';
  bool _voiceSendAfterStop = true;
  html.EventListener? _voiceDataListener;
  html.EventListener? _voiceStopListener;

  bool get isRecording => _isRecordingVoice;
  int get elapsedSec => _voiceRecordElapsedSec;

  String _pickVoiceMimeType() {
    const cands = ['audio/webm;codecs=opus', 'audio/webm', 'audio/mp4'];
    for (final c in cands) {
      if (html.MediaRecorder.isTypeSupported(c)) return c;
    }
    return 'audio/webm';
  }

  void abortRecording() {
    _wantVoiceRecord = false;
    _voiceSendAfterStop = false;
    _voiceRecordTicker?.cancel();
    _voiceRecordTicker = null;
    try {
      _voiceMediaRecorder?.stop();
    } catch (_) {}
    if (_voiceMediaRecorder != null && _voiceDataListener != null) {
      _voiceMediaRecorder!.removeEventListener('dataavailable', _voiceDataListener);
    }
    if (_voiceMediaRecorder != null && _voiceStopListener != null) {
      _voiceMediaRecorder!.removeEventListener('stop', _voiceStopListener);
    }
    _voiceDataListener = null;
    _voiceStopListener = null;
    _voiceMediaRecorder = null;
    _voiceChunks.clear();
    _voiceMediaStream?.getTracks().forEach((t) => t.stop());
    _voiceMediaStream = null;
    _isRecordingVoice = false;
    _voiceRecordElapsedSec = 0;
  }

  Future<void> beginRecording() async {
    _wantVoiceRecord = true;
    final md = html.window.navigator.mediaDevices;
    if (md == null) {
      onError('Tu navegador no permite grabar audio');
      return;
    }
    try {
      final stream = await md.getUserMedia({'audio': true});
      if (!_wantVoiceRecord) {
        stream.getTracks().forEach((t) => t.stop());
        return;
      }
      _voiceMimeUsed = _pickVoiceMimeType();
      _voiceChunks.clear();
      _voiceMediaStream = stream;
      final recorder = html.MediaRecorder(stream, {'mimeType': _voiceMimeUsed});
      _voiceMediaRecorder = recorder;

      _voiceDataListener = (html.Event e) {
        if (e is! html.BlobEvent) return;
        final blob = e.data;
        if (blob != null && blob.size > 0) _voiceChunks.add(blob);
      };
      recorder.addEventListener('dataavailable', _voiceDataListener);

      _voiceStopListener = (html.Event e) {
        recorder.removeEventListener('dataavailable', _voiceDataListener);
        recorder.removeEventListener('stop', _voiceStopListener);
        _voiceDataListener = null;
        _voiceStopListener = null;
        _voiceMediaRecorder = null;
        _voiceRecordTicker?.cancel();
        _voiceRecordTicker = null;
        _voiceMediaStream?.getTracks().forEach((t) => t.stop());
        _voiceMediaStream = null;

        final send = _voiceSendAfterStop;
        _voiceSendAfterStop = true;
        _isRecordingVoice = false;
        if (!send) {
          _voiceChunks.clear();
          onUiUpdate();
          return;
        }
        if (_voiceChunks.isEmpty) {
          onUiUpdate();
          onError('Grabación vacía o demasiado corta');
          return;
        }
        final blob = html.Blob(_voiceChunks, _voiceMimeUsed);
        _voiceChunks.clear();
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);
        reader.onLoad.listen((_) {
          final raw = reader.result;
          if (raw == null) return;
          if (raw is! ByteBuffer) return;
          final bytes = Uint8List.view(raw);
          if (bytes.isEmpty) {
            onUiUpdate();
            return;
          }
          final dur = _voiceRecordElapsedSec.clamp(1, 359999);
          _voiceRecordElapsedSec = 0;
          onRecorded(bytes, dur, _voiceMimeUsed);
          onUiUpdate();
        });
      };
      recorder.addEventListener('stop', _voiceStopListener);

      recorder.start();
      _isRecordingVoice = true;
      _voiceRecordElapsedSec = 0;
      _voiceRecordTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        _voiceRecordElapsedSec++;
        onUiUpdate();
      });
      onUiUpdate();
    } catch (e) {
      _wantVoiceRecord = false;
      onError('No se pudo usar el micrófono: $e');
    }
  }

  Future<void> endRecording({required bool send}) async {
    if (!_isRecordingVoice && !_wantVoiceRecord) return;
    if (!_isRecordingVoice) {
      _wantVoiceRecord = false;
      return;
    }
    _wantVoiceRecord = false;
    _voiceSendAfterStop = send;
    try {
      _voiceMediaRecorder?.stop();
    } catch (_) {}
    onUiUpdate();
  }

  void dispose() {
    abortRecording();
  }
}
