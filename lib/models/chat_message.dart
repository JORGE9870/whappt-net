import 'dart:convert';
import 'dart:typed_data';

Uint8List? decodeOptionalB64(String? s) {
  if (s == null || s.isEmpty) return null;
  try {
    return base64Decode(s);
  } catch (_) {
    return null;
  }
}

/// Mensaje de conversación (texto, adjuntos, nota de voz).
class ChatMsg {
  final String? text;
  final String? assetPath;
  final Uint8List? imageBytes;
  final Uint8List? fileBytes;
  final String? fileName;
  final int? fileSize;
  final String time;
  final DateTime? dateTime;
  final bool isMe;
  final bool isForwarded;
  final bool showForwardIconAside;
  final Uint8List? voiceBytes;
  final int? voiceDurationSec;
  final String? voiceMime;

  const ChatMsg({
    this.text,
    this.assetPath,
    this.imageBytes,
    this.fileBytes,
    this.fileName,
    this.fileSize,
    required this.time,
    this.dateTime,
    required this.isMe,
    this.isForwarded = false,
    this.showForwardIconAside = false,
    this.voiceBytes,
    this.voiceDurationSec,
    this.voiceMime,
  });

  ChatMsg copyWith({
    bool? isForwarded,
    bool? showForwardIconAside,
    String? time,
    DateTime? dateTime,
  }) =>
      ChatMsg(
        text: text,
        assetPath: assetPath,
        imageBytes: imageBytes,
        fileBytes: fileBytes,
        fileName: fileName,
        fileSize: fileSize,
        time: time ?? this.time,
        dateTime: dateTime ?? this.dateTime,
        isMe: isMe,
        isForwarded: isForwarded ?? this.isForwarded,
        showForwardIconAside: showForwardIconAside ?? this.showForwardIconAside,
        voiceBytes: voiceBytes,
        voiceDurationSec: voiceDurationSec,
        voiceMime: voiceMime,
      );

  Map<String, dynamic> toJson() => {
        if (text != null) 'text': text,
        if (assetPath != null) 'assetPath': assetPath,
        if (imageBytes != null) 'imageB64': base64Encode(imageBytes!),
        if (fileBytes != null) 'fileB64': base64Encode(fileBytes!),
        if (fileName != null) 'fileName': fileName,
        if (fileSize != null) 'fileSize': fileSize,
        'time': time,
        if (dateTime != null) 'dateTime': dateTime!.toIso8601String(),
        'isMe': isMe,
        'isForwarded': isForwarded,
        'showForwardIconAside': showForwardIconAside,
        if (voiceBytes != null) 'voiceB64': base64Encode(voiceBytes!),
        if (voiceDurationSec != null) 'voiceDurationSec': voiceDurationSec,
        if (voiceMime != null) 'voiceMime': voiceMime,
      };

  factory ChatMsg.fromJson(Map<String, dynamic> j) {
    return ChatMsg(
      text: j['text'] as String?,
      assetPath: j['assetPath'] as String?,
      imageBytes: decodeOptionalB64(j['imageB64'] as String?),
      fileBytes: decodeOptionalB64(j['fileB64'] as String?),
      fileName: j['fileName'] as String?,
      fileSize: j['fileSize'] as int?,
      time: j['time'] as String? ?? '',
      dateTime: j['dateTime'] != null ? DateTime.tryParse(j['dateTime'] as String) : null,
      isMe: j['isMe'] as bool? ?? false,
      isForwarded: j['isForwarded'] as bool? ?? false,
      showForwardIconAside: j['showForwardIconAside'] as bool? ?? false,
      voiceBytes: decodeOptionalB64(j['voiceB64'] as String?),
      voiceDurationSec: j['voiceDurationSec'] as int?,
      voiceMime: j['voiceMime'] as String?,
    );
  }
}

List<ChatMsg> defaultMessagesForChat(String chatName) {
  if (chatName != 'Claudia Fernandez Ips Sogamoso') return [];
  final d = DateTime(2026, 3, 28);
  return [
    ChatMsg(text: 'Hola mucho gusto mi nombre es Isabel Castro, te estoy escribiendo porque yo me hice un examen con ustedes en 2022 quisiera saber si sera posible que me renueve el examen', time: '10:15 a. m.', dateTime: d, isMe: true),
    ChatMsg(text: 'Hola  muy buena tarde habla con claudia africano. claro que si dame un momento y validamos en el sistema', time: '10:20 a. m.', dateTime: d, isMe: false),
    ChatMsg(text: 'me regalas tu numero de documento', time: '10:20 a. m.', dateTime: d, isMe: false),
    ChatMsg(text: 'Claro que si, mi número de documento es 1.057.593.972', time: '10:25 a. m.', dateTime: d, isMe: true),
    ChatMsg(text: ' si Claro podemos renovar tu examen lo unico que no podemos es generar una  facturas porque como no va quedar registro de que registramos ese registro de esa atencion ', time: '10:24 a. m.', dateTime: d, isMe: false),
    ChatMsg(text: 'bueno si', time: '10:25 a. m.', dateTime: d, isMe: true),
    ChatMsg(text: 'oye somo un grupo de 25 personas aproximamente tu nos podria hacer el certificado a todos?', time: '10:25 a. m.', dateTime: d, isMe: true),
    ChatMsg(text: 'claro que les podemos hacer un descuento y le podemos dejar el certificado en 25 mil pesos a cada uno le podemos hacer el examen ocupacional a cada uno van a tener que enviar una foto y los datos personales numero de cedula nombres completos y apellidos numero de cedula peso talla eps y una firma lo unico que ya te dije no van a tener una factura como tal como si lo ubira facturado aca del resto no van a tener ninguna complicacion .', time: '10:26 a. m.', dateTime: d, isMe: false),
    ChatMsg(text: 'oye pero estas totalmente segura que los examenes son veridicos si son osea si son verificables porque yo se que la profesora puede llamar para verificar si nos hicimos los examenes y pues es muy impotante que si queden registrados en la ips y pues usted vayan a decir que si no lo hicimo alla', time: '10:25 a. m.', dateTime: d, isMe: true),
    ChatMsg(text: 'Claro con el QR que los vamos a enviar los pueden verificar, incluso si llaman al número voy a ser yo quien atienda las llamadasi claro que si claro que si no te preocupes por eso', time: '10:25 a. m.', dateTime: d, isMe: false),
    ChatMsg(text: 'y pues los certificados son expedidos directamente de la IPS', time: '10:25 a. m.', dateTime: d, isMe: true),
    ChatMsg(text: 'Valery Alejandra Cristiano Gonzalez', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
    ChatMsg(text: '30/03/2002', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
    ChatMsg(text: '23 años', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
    ChatMsg(text: '56kg', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
    ChatMsg(text: 'valerycristiano3002@gmail.com', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
    ChatMsg(text: 'Tel:3142417815', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
    ChatMsg(text: '1000160930 .', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
    ChatMsg(assetPath: 'images/perfil.jpg', time: '11:06 p. m.', dateTime: d, isMe: true, isForwarded: true, showForwardIconAside: true),
  ];
}
