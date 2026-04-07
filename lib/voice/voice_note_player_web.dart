import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/material.dart';

/// Reproductor de nota de voz (web: AudioElement + blob URL).
class VoiceNotePlayRow extends StatefulWidget {
  final Uint8List bytes;
  final String mimeType;
  final int durationSec;

  const VoiceNotePlayRow({super.key, required this.bytes, required this.mimeType, required this.durationSec});

  @override
  State<VoiceNotePlayRow> createState() => _VoiceNotePlayRowState();
}

class _VoiceNotePlayRowState extends State<VoiceNotePlayRow> {
  bool _playing = false;
  html.AudioElement? _audio;
  String? _objectUrl;

  String get _label {
    final s = widget.durationSec.clamp(0, 359999);
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  void _toggle() {
    if (_playing) {
      _audio?.pause();
      try {
        _audio?.currentTime = 0;
      } catch (_) {}
      setState(() => _playing = false);
      return;
    }
    _objectUrl ??= html.Url.createObjectUrlFromBlob(html.Blob([widget.bytes], widget.mimeType));
    _audio ??= html.AudioElement()
      ..src = _objectUrl!
      ..onEnded.listen((_) {
        if (mounted) setState(() => _playing = false);
      });
    _audio!.play();
    setState(() => _playing = true);
  }

  @override
  void dispose() {
    _audio?.pause();
    final u = _objectUrl;
    if (u != null) html.Url.revokeObjectUrl(u);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(22),
            child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(color: Color(0xFF00A884), shape: BoxShape.circle),
              child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 26),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 3,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(_label, style: const TextStyle(color: Color(0xFF8696A0), fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
