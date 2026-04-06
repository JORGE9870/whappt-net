import 'package:flutter/material.dart';
import 'package:archive/archive.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:html' as html;
import 'dart:convert';
import 'dart:typed_data';

void main() {
  runApp(const WhatsAppClone());
}

class WhatsAppClone extends StatelessWidget {
  const WhatsAppClone({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B141B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0B141B),
          elevation: 0,
        ),
      ),
      builder: (context, child) => _PhoneShell(child: child ?? const SizedBox()),
      home: const LoginScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PHONE SHELL — muestra el marco de móvil en pantallas anchas (web/escritorio)
// ─────────────────────────────────────────────────────────────────────────────
class _PhoneShell extends StatelessWidget {
  final Widget child;
  const _PhoneShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        // En pantalla estrecha (móvil real) renderiza directo sin marco
        if (constraints.maxWidth <= 520) return child;

        return Container(
          // Fondo exacto del chat de WhatsApp (oscuro azul-pizarra)
          color: const Color(0xFF070D10),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _PhoneMockup(child: child),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PHONE MOCKUP — marco físico del teléfono con status bar, botones e indicador
// ─────────────────────────────────────────────────────────────────────────────
class _PhoneMockup extends StatelessWidget {
  final Widget child;
  const _PhoneMockup({required this.child});

  static const double _w = 390.0;
  static const double _h = 770.0;
  static const double _statusH = 52.0;
  static const double _homeH = 28.0;
  static const double _contentH = _h - _statusH - _homeH;
  static const double _frame = 12.0;
  static const double _radius = 46.0;
  static const double _btnOff = 12.0;
  static const double _btnW = 4.5;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _w + _frame * 2 + _btnOff + _btnW,
      height: _h + _frame * 2,
      child: Stack(
        children: [
          // Botón silencio (izquierda)
          Positioned(left: 0, top: 110, child: _sideButton(30)),
          // Volumen + (izquierda)
          Positioned(left: 0, top: 156, child: _sideButton(62)),
          // Volumen - (izquierda)
          Positioned(left: 0, top: 234, child: _sideButton(62)),
          // Encendido (derecha)
          Positioned(right: 0, top: 170, child: _sideButton(74)),
          // Cuerpo del teléfono
          Positioned(
            left: _btnOff + _btnW,
            top: 0,
            child: _buildPhoneBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneBody(BuildContext context) {
    return Container(
      width: _w + _frame * 2,
      height: _h + _frame * 2,
      decoration: BoxDecoration(
        // Marco con gradiente en la paleta oscura de WhatsApp
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F2C34), Color(0xFF0B141B), Color(0xFF121B22)],
        ),
        borderRadius: BorderRadius.circular(_radius + _frame),
        // Borde con el verde WhatsApp muy sutil
        border: Border.all(color: const Color(0xFF00A884), width: 0.6),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.9),
            blurRadius: 80,
            spreadRadius: 12,
            offset: const Offset(0, 24),
          ),
          // Resplandor verde WhatsApp muy tenue en el borde exterior
          BoxShadow(
            color: const Color(0xFF00A884).withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(_frame),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_radius),
          child: Column(
            children: [
              _buildStatusBar(),
              Expanded(
                child: MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    size: const Size(_w, _contentH),
                    padding: EdgeInsets.zero,
                    viewPadding: EdgeInsets.zero,
                    viewInsets: EdgeInsets.zero,
                  ),
                  child: child,
                ),
              ),
              _buildHomeIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sideButton(double height) => Container(
        width: _btnW,
        height: height,
        decoration: BoxDecoration(
          // Botones con el color secundario oscuro de WhatsApp
          color: const Color(0xFF1F2C34),
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _buildStatusBar() {
    return Container(
      height: _statusH,
      color: const Color(0xFF0B141B),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Positioned(
            left: 22,
            child: Text(
              '9:41',
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
          // Dynamic island
          Container(
            width: 126,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const Positioned(
            right: 18,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.signal_cellular_alt, color: Colors.white, size: 15),
                SizedBox(width: 4),
                Icon(Icons.wifi, color: Colors.white, size: 14),
                SizedBox(width: 4),
                Icon(Icons.battery_full, color: Colors.white, size: 15),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeIndicator() {
    return Container(
      height: _homeH,
      color: const Color(0xFF0B141B),
      child: Center(
        child: Container(
          width: 130,
          height: 5,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

// --- PANTALLA DE LOGIN ---
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _error = false;

  void _login() {
    if (_passCtrl.text == 'isabel123') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PhoneVerificationScreen()),
      );
    } else {
      setState(() => _error = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B141B),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo WhatsApp
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  color: const Color(0xFF00A884),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: const Color(0xFF00A884).withValues(alpha: 0.3), blurRadius: 24, spreadRadius: 4)],
                ),
                child: const Icon(Icons.lock, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 28),
              const Text('WhappsAt', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Ingresa tu clave para continuar', style: TextStyle(color: Color(0xFF8696A0), fontSize: 14)),
              const SizedBox(height: 36),
              // Campo clave
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                onChanged: (_) => setState(() => _error = false),
                onSubmitted: (_) => _login(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Contraseña',
                  hintStyle: const TextStyle(color: Color(0xFF8696A0)),
                  filled: true,
                  fillColor: const Color(0xFF1F2C34),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF00A884), width: 1.5)),
                  prefixIcon: const Icon(Icons.key, color: Color(0xFF8696A0)),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: const Color(0xFF8696A0)),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  errorText: _error ? 'Clave incorrecta' : null,
                  errorStyle: const TextStyle(color: Color(0xFFE53935)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A884),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- PANTALLA DE VERIFICACIÓN ---
class PhoneVerificationScreen extends StatefulWidget {
  const PhoneVerificationScreen({super.key});

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final String _selectedCountryCode = "+ 57";

  void _onNextPressed() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const ChatListScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () {}),
        actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Text(
              'Ingresa tu número de teléfono',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'WhatsApp necesitará verificar tu número de teléfono. Es posible que tu operador aplique cargos.',
              style: TextStyle(color: Color(0xFF8696A0), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const Text(
              '¿Cuál es mi número?',
              style: TextStyle(color: Color(0xFF00A884), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // País
            Container(
              width: 250,
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF00A884), width: 1.5))),
              child: const Row(
                children: [
                  Expanded(child: Text('Colombia', textAlign: TextAlign.center, style: TextStyle(fontSize: 16))),
                  Icon(Icons.arrow_drop_down, color: Color(0xFF00A884)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Teléfono
            SizedBox(
              width: 250,
              child: Row(
                children: [
                  Container(
                    width: 60,
                    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFF00A884), width: 1.5))),
                    child: Center(child: Text(_selectedCountryCode, style: const TextStyle(fontSize: 16))),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      onChanged: (v) => setState(() {}),
                      decoration: const InputDecoration(
                        hintText: 'Número de teléfono',
                        hintStyle: TextStyle(color: Color(0xFF8696A0)),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF00A884), width: 1.5)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: _phoneController.text.length > 5 ? _onNextPressed : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _phoneController.text.length > 5 ? const Color(0xFF00A884) : const Color(0xFF1F2C34),
                  foregroundColor: _phoneController.text.length > 5 ? Colors.black : const Color(0xFF8696A0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                ),
                child: const Text('Siguiente', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// --- PANTALLA LISTA DE CHATS ---
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WhatsApp', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          IconButton(icon: const Icon(Icons.camera_alt_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Búsqueda
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              height: 48,
              decoration: BoxDecoration(color: const Color(0xFF1F2C34), borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Color(0xFF8696A0)),
                  SizedBox(width: 12),
                  Text('Preguntar a Meta AI o buscar', style: TextStyle(color: Color(0xFF8696A0), fontSize: 15)),
                ],
              ),
            ),
          ),
          // Filtros
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              children: [
                _buildPill('Todos', true),
                _buildPill('No leídos', false, count: '5'),
                _buildPill('Favoritos', false),
                _buildPill('Grupos', false),
              ],
            ),
          ),
          // Lista
          Expanded(
            child: ListView(
              children: [
                _buildChatItem(context, 'Claudia Fernandez Ips Sogamoso', 'Foto', '11:06 p. m.', true, imagePath: 'images/perfil.jpg'),
                _buildChatItem(context, '+57 310 816 7689 (Tú)', 'Foto', '6:07 p. m.', true),
                _buildChatItem(context, 'mariachi silverio', '🤣🤣🤣', '2:44 p. m.', true),
                _buildChatItem(context, 'Silverio', 'Llamada perdida', '10:49 a. m.', false, isCall: true),
                _buildChatItem(context, 'Yurley', 'Mensaje de voz (0:02)', 'Ayer', true, isVoice: true),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00A884),
        child: const Icon(Icons.add_comment, color: Colors.black),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF121B22),
        selectedItemColor: const Color(0xFF00A884),
        unselectedItemColor: const Color(0xFF8696A0),
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chats'),
          BottomNavigationBarItem(icon: Icon(Icons.update), label: 'Novedades'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: 'Comunidades'),
          BottomNavigationBarItem(icon: Icon(Icons.call_outlined), label: 'Llamadas'),
        ],
      ),
    );
  }

  Widget _buildPill(String text, bool active, {String? count}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF00A884).withOpacity(0.2) : const Color(0xFF1F2C34),
        borderRadius: BorderRadius.circular(20),
        border: active ? Border.all(color: const Color(0xFF00A884).withOpacity(0.6)) : null,
      ),
      child: Row(
        children: [
          Text(text, style: TextStyle(color: active ? const Color(0xFF00A884) : const Color(0xFF8696A0), fontWeight: FontWeight.bold)),
          if (count != null) ...[const SizedBox(width: 4), Text(count, style: const TextStyle(fontSize: 12, color: Color(0xFF8696A0)))],
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, String name, String msg, String time, bool read, {bool isCall = false, bool isVoice = false, String? imagePath}) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: const Color(0xFF1F2C34),
        backgroundImage: imagePath != null ? AssetImage(imagePath) : null,
        child: imagePath == null ? const Icon(Icons.person, color: Colors.white, size: 30) : null,
      ),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Row(
        children: [
          if (!isCall) const Icon(Icons.done_all, color: Colors.blue, size: 16),
          if (isCall) const Icon(Icons.call_missed, color: Colors.red, size: 16),
          const SizedBox(width: 4),
          if (isVoice) const Icon(Icons.mic, color: Color(0xFF8696A0), size: 16),
          Expanded(child: Text(msg, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF8696A0)))),
        ],
      ),
      trailing: Text(time, style: const TextStyle(color: Color(0xFF8696A0), fontSize: 12)),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => ChatDetailScreen(name: name)));
      },
    );
  }
}

// Modelo de mensaje
class _ChatMsg {
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
  /// Ícono circular >> al lado de la imagen (independiente del texto "Reenviado")
  final bool showForwardIconAside;
  /// Nota de voz (WebM/Opus en navegador)
  final Uint8List? voiceBytes;
  final int? voiceDurationSec;
  final String? voiceMime;
  const _ChatMsg({
    this.text, this.assetPath, this.imageBytes, this.fileBytes, this.fileName, this.fileSize,
    required this.time, this.dateTime, required this.isMe, this.isForwarded = false, this.showForwardIconAside = false,
    this.voiceBytes, this.voiceDurationSec, this.voiceMime,
  });

  _ChatMsg copyWith({
    bool? isForwarded,
    bool? showForwardIconAside,
    String? time,
    DateTime? dateTime,
  }) => _ChatMsg(
    text: text, assetPath: assetPath, imageBytes: imageBytes,
    fileBytes: fileBytes, fileName: fileName, fileSize: fileSize,
    time: time ?? this.time,
    dateTime: dateTime ?? this.dateTime,
    isMe: isMe,
    isForwarded: isForwarded ?? this.isForwarded,
    showForwardIconAside: showForwardIconAside ?? this.showForwardIconAside,
    voiceBytes: voiceBytes, voiceDurationSec: voiceDurationSec, voiceMime: voiceMime,
  );
}

// --- PANTALLA DE CONVERSACIÓN ---
class ChatDetailScreen extends StatefulWidget {
  final String name;
  const ChatDetailScreen({super.key, required this.name});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  late List<_ChatMsg> _msgs;
  bool _sendingAsMe = true;
  Uint8List? _contactPhoto; // foto de perfil del contacto

  // Grabación de nota de voz (navegador)
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

  @override
  void initState() {
    super.initState();
    final d = DateTime(2026, 3, 28);
    _msgs = [
      _ChatMsg(text: 'Hola mucho gusto mi nombre es Isabel Castro, te estoy escribiendo porque yo me hice un examen con ustedes en 2022 quisiera saber si sera posible que me renueve el examen', time: '10:15 a. m.', dateTime: d, isMe: true),
      _ChatMsg(text: 'Hola  muy buena tarde habla con claudia africano. claro que si dame un momento y validamos en el sistema', time: '10:20 a. m.', dateTime: d, isMe: false),
      _ChatMsg(text: 'me regalas tu numero de documento', time: '10:20 a. m.', dateTime: d, isMe: false),
      _ChatMsg(text: 'Claro que si, mi número de documento es 1.057.593.972', time: '10:25 a. m.', dateTime: d, isMe: true),
      _ChatMsg(text: ' si Claro podemos renovar tu examen lo unico que no podemos es generar una  facturas porque como no va quedar registro de que registramos ese registro de esa atencion ', time: '10:24 a. m.', dateTime: d, isMe: false),
      _ChatMsg(text: 'bueno si', time: '10:25 a. m.', dateTime: d, isMe: true),
      _ChatMsg(text: 'oye somo un grupo de 25 personas aproximamente tu nos podria hacer el certificado a todos?', time: '10:25 a. m.', dateTime: d, isMe: true),
      _ChatMsg(text: 'claro que les podemos hacer un descuento y le podemos dejar el certificado en 25 mil pesos a cada uno le podemos hacer el examen ocupacional a cada uno van a tener que enviar una foto y los datos personales numero de cedula nombres completos y apellidos numero de cedula peso talla eps y una firma lo unico que ya te dije no van a tener una factura como tal como si lo ubira facturado aca del resto no van a tener ninguna complicacion .', time: '10:26 a. m.', dateTime: d, isMe: false),
      _ChatMsg(text: 'oye pero estas totalmente segura que los examenes son veridicos si son osea si son verificables porque yo se que la profesora puede llamar para verificar si nos hicimos los examenes y pues es muy impotante que si queden registrados en la ips y pues usted vayan a decir que si no lo hicimo alla', time: '10:25 a. m.', dateTime: d, isMe: true),
      _ChatMsg(text: 'Claro con el QR que los vamos a enviar los pueden verificar, incluso si llaman al número voy a ser yo quien atienda las llamadasi claro que si claro que si no te preocupes por eso', time: '10:25 a. m.', dateTime: d, isMe: false),
      _ChatMsg(text: 'y pues los certificados son expedidos directamente de la IPS', time: '10:25 a. m.', dateTime: d, isMe: true),
      _ChatMsg(text: 'Valery Alejandra Cristiano Gonzalez', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
      _ChatMsg(text: '30/03/2002', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
      _ChatMsg(text: '23 años', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
      _ChatMsg(text: '56kg', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
      _ChatMsg(text: 'valerycristiano3002@gmail.com', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
      _ChatMsg(text: 'Tel:3142417815', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
      _ChatMsg(text: '1000160930 .', time: '11:05 p. m.', dateTime: d, isMe: true, isForwarded: true),
      _ChatMsg(assetPath: 'images/perfil.jpg', time: '11:06 p. m.', dateTime: d, isMe: true, isForwarded: true, showForwardIconAside: true),
    ];
  }

  @override
  void dispose() {
    _abortVoiceRecording();
    _voiceRecordTicker?.cancel();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  String _fmtVoiceDuration(int sec) {
    final s = sec.clamp(0, 359999);
    return '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
  }

  String _pickVoiceMimeType() {
    const cands = ['audio/webm;codecs=opus', 'audio/webm', 'audio/mp4'];
    for (final c in cands) {
      if (html.MediaRecorder.isTypeSupported(c)) return c;
    }
    return 'audio/webm';
  }

  void _abortVoiceRecording() {
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

  Future<void> _beginVoiceRecording() async {
    if (_textCtrl.text.isNotEmpty) return;
    _wantVoiceRecord = true;
    final md = html.window.navigator.mediaDevices;
    if (md == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tu navegador no permite grabar audio'), backgroundColor: Color(0xFFE53935)),
        );
      }
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
          if (mounted) setState(() {});
          return;
        }
        if (_voiceChunks.isEmpty) {
          if (mounted) {
            setState(() {});
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Grabación vacía o demasiado corta'), backgroundColor: Color(0xFF8696A0)),
            );
          }
          return;
        }
        final blob = html.Blob(_voiceChunks, _voiceMimeUsed);
        _voiceChunks.clear();
        final reader = html.FileReader();
        reader.readAsArrayBuffer(blob);
        reader.onLoad.listen((_) {
          if (!mounted) return;
          final raw = reader.result;
          if (raw == null) return;
          if (raw is! ByteBuffer) return;
          final bytes = Uint8List.view(raw);
          if (bytes.isEmpty) {
            setState(() {});
            return;
          }
          final dur = _voiceRecordElapsedSec.clamp(1, 359999);
          setState(() {
            _voiceRecordElapsedSec = 0;
            _msgs.add(_ChatMsg(
              voiceBytes: bytes,
              voiceDurationSec: dur,
              voiceMime: _voiceMimeUsed,
              time: _now(),
              dateTime: DateTime.now(),
              isMe: _sendingAsMe,
            ));
          });
          _scrollToBottom();
        });
      };
      recorder.addEventListener('stop', _voiceStopListener);

      recorder.start();
      _isRecordingVoice = true;
      _voiceRecordElapsedSec = 0;
      _voiceRecordTicker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() => _voiceRecordElapsedSec++);
      });
      if (mounted) setState(() {});
    } catch (e) {
      _wantVoiceRecord = false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo usar el micrófono: $e'), backgroundColor: const Color(0xFFE53935)),
        );
      }
    }
  }

  void _endVoiceRecording({required bool send}) {
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
    if (mounted) setState(() {});
  }

  String _now() => _formatTimeLabel(DateTime.now());

  /// Misma forma que WhatsApp en la app: "h:mm a. m.|p. m."
  String _formatTimeLabel(DateTime t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m ${t.hour >= 12 ? "p. m." : "a. m."}';
  }

  Future<void> _editMessageTime(int index) async {
    final msg = _msgs[index];
    final base = msg.dateTime ?? DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: base.hour, minute: base.minute),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF00A884), surface: Color(0xFF1F2C34)),
        ),
        child: child!,
      ),
    );
    if (picked == null || !mounted) return;
    final newDt = DateTime(base.year, base.month, base.day, picked.hour, picked.minute);
    setState(() {
      _msgs[index] = msg.copyWith(time: _formatTimeLabel(newDt), dateTime: newDt);
    });
  }

  void _sendText() {
    final txt = _textCtrl.text.trim();
    if (txt.isEmpty) return;
    setState(() {
      _msgs.add(_ChatMsg(text: txt, time: _now(), dateTime: DateTime.now(), isMe: _sendingAsMe));
      _textCtrl.clear();
    });
    _scrollToBottom();
  }

  void _pickImage() {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((_) {
      final file = input.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoad.listen((_) {
        final bytes = Uint8List.fromList(reader.result as List<int>);
        if (mounted) {
          setState(() => _msgs.add(_ChatMsg(imageBytes: bytes, time: _now(), dateTime: DateTime.now(), isMe: _sendingAsMe)));
          _scrollToBottom();
        }
      });
    });
  }

  void _pickFile() {
    final input = html.FileUploadInputElement()..accept = 'image/*,application/pdf,.pdf,.doc,.docx,.xls,.xlsx,.txt';
    input.click();
    input.onChange.listen((_) {
      final file = input.files?.first;
      if (file == null) return;
      final isImage = file.type.startsWith('image/');
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoad.listen((_) {
        final bytes = Uint8List.fromList(reader.result as List<int>);
        if (mounted) {
          setState(() {
            if (isImage) {
              _msgs.add(_ChatMsg(imageBytes: bytes, time: _now(), dateTime: DateTime.now(), isMe: _sendingAsMe));
            } else {
              _msgs.add(_ChatMsg(fileBytes: bytes, fileName: file.name, fileSize: file.size, time: _now(), dateTime: DateTime.now(), isMe: _sendingAsMe));
            }
          });
          _scrollToBottom();
        }
      });
    });
  }

  void _confirmDelete(int index) {
    final msg = _msgs[index];
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2C34),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(margin: const EdgeInsets.only(top: 8, bottom: 4), width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF8696A0), borderRadius: BorderRadius.circular(2))),
            ListTile(
              leading: Icon(
                msg.isForwarded ? Icons.remove_circle_outline : Icons.reply_all,
                color: const Color(0xFF00A884),
              ),
              title: Text(
                msg.isForwarded ? 'Quitar "Reenviado"' : 'Marcar como reenviado',
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _msgs[index] = msg.copyWith(isForwarded: !msg.isForwarded));
              },
            ),
            if (msg.text != null || msg.imageBytes != null || msg.assetPath != null || msg.voiceBytes != null) ...[
              const Divider(color: Color(0xFF2A3942), height: 1),
              ListTile(
                leading: Icon(
                  msg.showForwardIconAside ? Icons.visibility_off_outlined : Icons.forward,
                  color: const Color(0xFF00A884),
                ),
                title: Text(
                  msg.showForwardIconAside ? 'Quitar ícono de reenvío al lado' : 'Ícono de reenvío al lado',
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() => _msgs[index] = msg.copyWith(showForwardIconAside: !msg.showForwardIconAside));
                },
              ),
            ],
            const Divider(color: Color(0xFF2A3942), height: 1),
            ListTile(
              leading: const Icon(Icons.schedule, color: Color(0xFF00A884)),
              title: const Text('Modificar hora', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _editMessageTime(index);
              },
            ),
            const Divider(color: Color(0xFF2A3942), height: 1),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
              title: const Text('Eliminar mensaje', style: TextStyle(color: Color(0xFFE53935))),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _msgs.removeAt(index));
              },
            ),
            ListTile(
              leading: const Icon(Icons.close, color: Color(0xFF8696A0)),
              title: const Text('Cancelar', style: TextStyle(color: Color(0xFF8696A0))),
              onTap: () => Navigator.pop(ctx),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _pickContactPhoto() {
    final input = html.FileUploadInputElement()..accept = 'image/*';
    input.click();
    input.onChange.listen((_) {
      final file = input.files?.first;
      if (file == null) return;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onLoad.listen((_) {
        final bytes = Uint8List.fromList(reader.result as List<int>);
        if (mounted) setState(() => _contactPhoto = bytes);
      });
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: _pickContactPhoto,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF1F2C34),
                    backgroundImage: _contactPhoto != null
                        ? MemoryImage(_contactPhoto!) as ImageProvider
                        : const AssetImage('images/perfil.jpg'),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 13, height: 13,
                      decoration: const BoxDecoration(color: Color(0xFF00A884), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 8, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'export') {
                _exportChatFile(context);
              } else if (value == 'clear') {
                _confirmClearChat();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'info', child: Text('Info. del contacto')),
              const PopupMenuItem(value: 'export', child: Text('Exportar chat')),
              const PopupMenuItem(value: 'clear', child: Text('Vaciar chat')),
              const PopupMenuItem(value: 'block', child: Text('Bloquear')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset('images/WhatsApp Image 2026-04-02 at 9.30.47 PM.jpeg', fit: BoxFit.cover)),
          Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollCtrl,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  itemCount: _msgs.length,
                  itemBuilder: (ctx, i) {
                    final m = _msgs[i];
                    Widget bubble;
                    if (m.voiceBytes != null && m.voiceDurationSec != null) {
                      bubble = _buildVoiceMessage(
                        m.voiceBytes!,
                        m.voiceMime ?? 'audio/webm',
                        m.voiceDurationSec!,
                        m.time,
                        m.isMe,
                      );
                    } else if (m.imageBytes != null) {
                      bubble = _buildBytesImage(
                        m.imageBytes!, m.time, m.isMe,
                        isForwarded: m.isForwarded, showForwardIconAside: m.showForwardIconAside,
                      );
                    } else if (m.fileBytes != null) {
                      bubble = _buildFileMessage(m.fileName ?? 'archivo', m.fileSize ?? 0, m.fileBytes!, m.time, m.isMe);
                    } else if (m.assetPath != null) {
                      bubble = _buildImageMessage(
                        m.assetPath!, m.time, m.isMe,
                        isForwarded: m.isForwarded, showForwardIconAside: m.showForwardIconAside,
                      );
                    } else {
                      bubble = _buildMessage(
                        m.text ?? '', m.time, m.isMe,
                        isForwarded: m.isForwarded, showForwardIconAside: m.showForwardIconAside,
                      );
                    }

                    return GestureDetector(
                      onLongPress: () => _confirmDelete(i),
                      child: bubble,
                    );
                  },
                ),
              ),
              // Toggle quién envía
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _sendingAsMe = true),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: _sendingAsMe ? const Color(0xFF00A884) : const Color(0xFF1F2C34),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                        ),
                        child: Text('Yo', style: TextStyle(color: _sendingAsMe ? Colors.black : const Color(0xFF8696A0), fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _sendingAsMe = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: !_sendingAsMe ? const Color(0xFF1F2C34).withValues(alpha: 0.9) : const Color(0xFF1F2C34),
                          borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
                          border: !_sendingAsMe ? Border.all(color: const Color(0xFF8696A0), width: 1) : null,
                        ),
                        child: Text(widget.name.split(' ').first, style: TextStyle(color: !_sendingAsMe ? Colors.white : const Color(0xFF8696A0), fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                ),
              ),
              if (_isRecordingVoice)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2C34),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.7)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.fiber_manual_record, color: Color(0xFFE53935), size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Grabando… ${_fmtVoiceDuration(_voiceRecordElapsedSec)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Suelta el botón para enviar',
                            style: TextStyle(color: Color(0xFF8696A0), fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Input de mensaje
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(color: const Color(0xFF1F2C34), borderRadius: BorderRadius.circular(24)),
                        child: Row(
                          children: [
                            const Padding(padding: EdgeInsets.all(10), child: Icon(Icons.emoji_emotions_outlined, color: Color(0xFF8696A0))),
                            Expanded(
                              child: TextField(
                                controller: _textCtrl,
                                onSubmitted: (_) => _sendText(),
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(hintText: 'Escribe un mensaje', border: InputBorder.none, hintStyle: TextStyle(color: Color(0xFF8696A0))),
                              ),
                            ),
                            IconButton(icon: const Icon(Icons.attach_file, color: Color(0xFF8696A0)), onPressed: _pickFile),
                            IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF8696A0)), onPressed: _pickImage),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Listener(
                      behavior: HitTestBehavior.opaque,
                      onPointerDown: (_) {
                        if (_textCtrl.text.isEmpty) {
                          _beginVoiceRecording();
                        }
                      },
                      onPointerUp: (_) {
                        if (_textCtrl.text.isNotEmpty) {
                          _sendText();
                        } else {
                          _endVoiceRecording(send: true);
                        }
                      },
                      onPointerCancel: (_) {
                        if (_textCtrl.text.isEmpty) {
                          _endVoiceRecording(send: false);
                        }
                      },
                      child: CircleAvatar(
                        backgroundColor: _isRecordingVoice
                            ? const Color(0xFFE53935)
                            : const Color(0xFF00A884),
                        radius: 24,
                        child: Icon(
                          _textCtrl.text.isNotEmpty ? Icons.send : Icons.mic,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceMessage(Uint8List bytes, String mime, int durationSec, String time, bool isMe) {
    final color = isMe ? const Color(0xFF003C2F) : const Color(0xFF101C23);
    return Padding(
      padding: EdgeInsets.only(left: isMe ? 58 : 4, right: isMe ? 4 : 58, bottom: 2),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) SizedBox(width: 8, height: 11, child: CustomPaint(painter: _TailPainter(color: color, isMe: false))),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 280),
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 7.5 : 0),
                  topRight: Radius.circular(isMe ? 0 : 7.5),
                  bottomLeft: const Radius.circular(7.5),
                  bottomRight: const Radius.circular(7.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _VoiceNotePlayRow(bytes: bytes, mimeType: mime, durationSec: durationSec),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(time, style: const TextStyle(color: Color(0xFF8696A0), fontSize: 11)),
                      if (isMe) ...[const SizedBox(width: 3), const Icon(Icons.done_all, color: Color(0xFF53BDEB), size: 15)],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) SizedBox(width: 8, height: 11, child: CustomPaint(painter: _TailPainter(color: color, isMe: true))),
        ],
      ),
    );
  }

  // Imagen desde memoria (fotos adjuntadas por el usuario)
  Widget _buildBytesImage(
    Uint8List bytes, String time, bool isMe, {
    bool isForwarded = false,
    bool showForwardIconAside = false,
  }) {
    final color = isMe ? const Color(0xFF003C2F) : const Color(0xFF101C23);
    return Padding(
      padding: EdgeInsets.only(left: isMe ? 58 : 4, right: isMe ? 4 : 58, bottom: 2),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) SizedBox(width: 8, height: 11, child: CustomPaint(painter: _TailPainter(color: color, isMe: false))),
          if (showForwardIconAside)
            Padding(
              padding: const EdgeInsets.only(right: 6, top: 160),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _ForwardArrow(size: 22, color: Colors.white.withValues(alpha: 0.9)),
                ),
              ),
            ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 7.5 : 0),
                  topRight: Radius.circular(isMe ? 0 : 7.5),
                  bottomLeft: const Radius.circular(7.5),
                  bottomRight: const Radius.circular(7.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isForwarded)
                    Padding(
                      padding: const EdgeInsets.only(left: 6, top: 4, bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _ForwardArrow(size: 14),
                          const SizedBox(width: 3),
                          const Text('Reenviado', style: TextStyle(color: Color(0xFF8696A0), fontSize: 11.5, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ClipRRect(borderRadius: BorderRadius.circular(6), child: Image.memory(bytes, fit: BoxFit.cover)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 3, 4, 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(time, style: const TextStyle(color: Color(0xFF8696A0), fontSize: 11)),
                        if (isMe) ...[const SizedBox(width: 3), const Icon(Icons.done_all, color: Color(0xFF53BDEB), size: 15)],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe) SizedBox(width: 8, height: 11, child: CustomPaint(painter: _TailPainter(color: color, isMe: true))),
        ],
      ),
    );
  }

  Widget _buildFileMessage(String fileName, int fileSize, Uint8List bytes, String time, bool isMe) {
    final color = isMe ? const Color(0xFF003C2F) : const Color(0xFF101C23);
    final ext = fileName.contains('.') ? fileName.split('.').last.toUpperCase() : 'DOC';
    final sizeTxt = fileSize > 1024 * 1024
        ? '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(fileSize / 1024).toStringAsFixed(0)} KB';

    // Color del ícono según extensión
    final iconColor = ext == 'PDF'
        ? const Color(0xFFE53935)
        : ext == 'XLS' || ext == 'XLSX'
            ? const Color(0xFF43A047)
            : ext == 'DOC' || ext == 'DOCX'
                ? const Color(0xFF1E88E5)
                : const Color(0xFF8696A0);

    return Padding(
      padding: EdgeInsets.only(left: isMe ? 58 : 4, right: isMe ? 4 : 58, bottom: 2),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) SizedBox(width: 8, height: 11, child: CustomPaint(painter: _TailPainter(color: color, isMe: false))),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 320),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 7.5 : 0),
                  topRight: Radius.circular(isMe ? 0 : 7.5),
                  bottomLeft: const Radius.circular(7.5),
                  bottomRight: const Radius.circular(7.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Ícono del archivo
                      Container(
                        width: 42, height: 48,
                        decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.insert_drive_file, color: iconColor, size: 22),
                            Text(ext, style: TextStyle(color: iconColor, fontSize: 8, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Nombre y tamaño
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(fileName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500), maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 3),
                            Text(sizeTxt, style: const TextStyle(color: Color(0xFF8696A0), fontSize: 11)),
                          ],
                        ),
                      ),
                      // Botón descargar
                      IconButton(
                        icon: const Icon(Icons.download, color: Color(0xFF8696A0), size: 20),
                        onPressed: () {
                          final blob = html.Blob([bytes]);
                          final url = html.Url.createObjectUrlFromBlob(blob);
                          html.AnchorElement(href: url)..setAttribute('download', fileName)..click();
                          html.Url.revokeObjectUrl(url);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(time, style: const TextStyle(color: Color(0xFF8696A0), fontSize: 11)),
                      if (isMe) ...[const SizedBox(width: 3), const Icon(Icons.done_all, color: Color(0xFF53BDEB), size: 15)],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isMe) SizedBox(width: 8, height: 11, child: CustomPaint(painter: _TailPainter(color: color, isMe: true))),
        ],
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Vaciar chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          '¿Borrar todos los mensajes de esta conversación? No se puede deshacer.',
          style: TextStyle(color: Color(0xFF8696A0)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: Color(0xFF8696A0))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _msgs.clear());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chat vaciado'), backgroundColor: Color(0xFF00A884)),
              );
            },
            child: const Text('Vaciar', style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _exportChatFile(BuildContext context) {
    final contactFirstName = widget.name.split(' ').first;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1F2C34),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Exportar chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text('¿Cómo deseas exportar la conversación?', style: TextStyle(color: Color(0xFF8696A0))),
        actions: [
          // Sin archivos — solo .txt
          TextButton.icon(
            icon: const Icon(Icons.text_snippet_outlined, color: Color(0xFF8696A0)),
            label: const Text('Sin archivos', style: TextStyle(color: Color(0xFF8696A0))),
            onPressed: () {
              Navigator.pop(ctx);
              _doExportTxt(contactFirstName);
            },
          ),
          // Con archivos — ZIP
          ElevatedButton.icon(
            icon: const Icon(Icons.folder_zip_outlined, color: Colors.black),
            label: const Text('Con archivos', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A884), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
            onPressed: () {
              Navigator.pop(ctx);
              _doExportZip(contactFirstName);
            },
          ),
        ],
      ),
    );
  }

  // Genera el texto del chat en formato WhatsApp
  String _buildChatTxt(String contactFirstName) {
    String fmtDate(DateTime? dt) => dt == null ? '' : '${dt.day}/${dt.month}/${dt.year}';
    final lines = StringBuffer();
    final firstDate = _msgs.isNotEmpty ? fmtDate(_msgs.first.dateTime) : fmtDate(DateTime.now());
    lines.writeln('$firstDate, 12:00 a. m. - Los mensajes y las llamadas están cifrados de extremo a extremo. Solo las personas en este chat pueden leerlos, escucharlos o compartirlos. *Obtén más información*.');
    lines.writeln();
    int mediaCount = 1;
    for (final m in _msgs) {
      final prefix = '${fmtDate(m.dateTime)}, ${m.time} - ${m.isMe ? "Yo" : contactFirstName}: ';
      if (m.text != null) {
        lines.writeln('$prefix${m.text}');
      } else if (m.voiceBytes != null) {
        lines.writeln('$prefix''Nota de voz (${m.voiceDurationSec ?? 0}s)');
      } else if (m.imageBytes != null) {
        lines.writeln('${prefix}IMG-$mediaCount.jpg (archivo adjunto)');
        mediaCount++;
      } else if (m.assetPath != null) {
        lines.writeln('${prefix}imagen omitida');
      } else if (m.fileBytes != null) {
        lines.writeln('$prefix${m.fileName ?? 'archivo_$mediaCount'} (archivo adjunto)');
        mediaCount++;
      }
    }
    return lines.toString();
  }

  // Exportar solo TXT
  void _doExportTxt(String contactFirstName) {
    final txt = _buildChatTxt(contactFirstName);
    final bytes = utf8.encode(txt);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'Chat de WhatsApp con $contactFirstName.txt')
      ..click();
    html.Url.revokeObjectUrl(url);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chat exportado (.txt)'), backgroundColor: Color(0xFF00A884)),
    );
  }

  // Exportar ZIP con TXT + todos los archivos adjuntos
  void _doExportZip(String contactFirstName) {
    final archive = Archive();

    // Agregar el .txt
    final txtBytes = utf8.encode(_buildChatTxt(contactFirstName));
    archive.addFile(ArchiveFile('Chat de WhatsApp con $contactFirstName.txt', txtBytes.length, txtBytes));

    // Agregar cada archivo/imagen de la conversación
    int imgCount = 1;
    int fileCount = 1;
    int voiceCount = 1;
    for (final m in _msgs) {
      if (m.voiceBytes != null) {
        final ext = (m.voiceMime ?? '').contains('mp4') ? 'm4a' : 'webm';
        final name = 'VOZ-$voiceCount.$ext';
        archive.addFile(ArchiveFile(name, m.voiceBytes!.length, m.voiceBytes!));
        voiceCount++;
      } else if (m.imageBytes != null) {
        final name = 'IMG-$imgCount.jpg';
        archive.addFile(ArchiveFile(name, m.imageBytes!.length, m.imageBytes!));
        imgCount++;
      } else if (m.fileBytes != null && m.fileName != null) {
        archive.addFile(ArchiveFile(m.fileName!, m.fileBytes!.length, m.fileBytes!));
        fileCount++;
      }
    }

    // Codificar ZIP y descargar
    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes == null) return;
    final blob = html.Blob([Uint8List.fromList(zipBytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
      ..setAttribute('download', 'Chat de WhatsApp con $contactFirstName.zip')
      ..click();
    html.Url.revokeObjectUrl(url);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Exportado: ${imgCount - 1} imágenes + ${fileCount - 1} archivos'), backgroundColor: const Color(0xFF00A884)),
    );
  }

  Widget _buildMessage(String text, String time, bool isMe, {bool isForwarded = false, bool showForwardIconAside = false}) {
    final color = isMe ? const Color(0xFF003C2F) : const Color(0xFF101C23);
    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 58 : 4,
        right: isMe ? 4 : 58,
        bottom: 2,
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!isMe)
              Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox(
                  width: 8, height: 11,
                  child: CustomPaint(painter: _TailPainter(color: color, isMe: false)),
                ),
              ),
            if (showForwardIconAside)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _ForwardArrow(size: 22, color: Colors.white.withValues(alpha: 0.9)),
                    ),
                  ),
                ),
              ),
            Flexible(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 320),
                padding: const EdgeInsets.fromLTRB(9, 6, 9, 6),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(isMe ? 7.5 : 0),
                    topRight: Radius.circular(isMe ? 0 : 7.5),
                    bottomLeft: const Radius.circular(7.5),
                    bottomRight: const Radius.circular(7.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isForwarded)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const _ForwardArrow(size: 14),
                            const SizedBox(width: 3),
                            const Text('Reenviado', style: TextStyle(color: Color(0xFF8696A0), fontSize: 11.5, fontStyle: FontStyle.italic)),
                          ],
                        ),
                      ),
                    Text(text, style: const TextStyle(color: Colors.white, fontSize: 14.5, height: 1.35)),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Expanded(child: SizedBox(width: 24)),
                        Text(time, style: const TextStyle(color: Color(0xFF8696A0), fontSize: 11)),
                        if (isMe) ...[
                          const SizedBox(width: 3),
                          const Icon(Icons.done_all, color: Color(0xFF53BDEB), size: 15),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isMe)
              Align(
                alignment: Alignment.bottomRight,
                child: SizedBox(
                  width: 8, height: 11,
                  child: CustomPaint(painter: _TailPainter(color: color, isMe: true)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageMessage(String assetPath, String time, bool isMe, {bool isForwarded = false, bool showForwardIconAside = false}) {
    final color = isMe ? const Color(0xFF003C2F) : const Color(0xFF101C23);
    return Padding(
      padding: EdgeInsets.only(
        left: isMe ? 58 : 4,
        right: isMe ? 4 : 58,
        bottom: 2,
      ),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            SizedBox(
              width: 8, height: 11,
              child: CustomPaint(painter: _TailPainter(color: color, isMe: false)),
            ),
          if (showForwardIconAside)
            Padding(
              padding: const EdgeInsets.only(right: 6, top: 160),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: _ForwardArrow(size: 22, color: Colors.white.withValues(alpha: 0.9)),
                ),
              ),
            ),
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 300),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isMe ? 7.5 : 0),
                  topRight: Radius.circular(isMe ? 0 : 7.5),
                  bottomLeft: const Radius.circular(7.5),
                  bottomRight: const Radius.circular(7.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isForwarded)
                    Padding(
                      padding: const EdgeInsets.only(left: 6, top: 4, bottom: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const _ForwardArrow(size: 14),
                          const SizedBox(width: 3),
                          const Text('Reenviado', style: TextStyle(color: Color(0xFF8696A0), fontSize: 11.5, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(assetPath, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 3, 4, 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(time, style: const TextStyle(color: Color(0xFF8696A0), fontSize: 11)),
                        if (isMe) ...[
                          const SizedBox(width: 3),
                          const Icon(Icons.done_all, color: Color(0xFF53BDEB), size: 15),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isMe)
            SizedBox(
              width: 8, height: 11,
              child: CustomPaint(painter: _TailPainter(color: color, isMe: true)),
            ),
        ],
      ),
    );
  }
}

/// Reproductor de nota de voz en web (AudioElement + blob URL)
class _VoiceNotePlayRow extends StatefulWidget {
  final Uint8List bytes;
  final String mimeType;
  final int durationSec;
  const _VoiceNotePlayRow({required this.bytes, required this.mimeType, required this.durationSec});

  @override
  State<_VoiceNotePlayRow> createState() => _VoiceNotePlayRowState();
}

class _VoiceNotePlayRowState extends State<_VoiceNotePlayRow> {
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

// Pintor de garabatos para el fondo
class DoodlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final random = math.Random(123); // Semilla fija para consistencia
    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final s = random.nextDouble() * 15 + 10;
      
      final shapeType = random.nextInt(5);
      if (shapeType == 0) canvas.drawCircle(Offset(x, y), s / 4, paint);
      else if (shapeType == 1) canvas.drawRect(Rect.fromLTWH(x, y, s, s/2), paint);
      else if (shapeType == 2) {
        canvas.drawLine(Offset(x, y), Offset(x + s, y + s), paint);
        canvas.drawLine(Offset(x + s, y), Offset(x, y + s), paint);
      } else if (shapeType == 3) {
        final path = Path()..moveTo(x, y)..lineTo(x + s/2, y-s/2)..lineTo(x+s, y)..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawArc(Rect.fromLTWH(x, y, s, s), 0, 3, false, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Flecha doble de "Reenviado" (estilo WhatsApp >>)
class _ForwardArrow extends StatelessWidget {
  final double size;
  final Color color;
  const _ForwardArrow({this.size = 14, this.color = const Color(0xFF8696A0)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ForwardArrowPainter(color: color),
      size: Size(size, size),
    );
  }
}

class _ForwardArrowPainter extends CustomPainter {
  final Color color;
  const _ForwardArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;

    // Palo: sube y luego va largo horizontal hacia la derecha
    final stem = Path()
      ..moveTo(w * 0.08, h * 0.92)   // base del palo
      ..lineTo(w * 0.08, h * 0.58)   // sube recto
      ..quadraticBezierTo(
        w * 0.08, h * 0.46,          // esquina redondeada suave
        w * 0.20, h * 0.46,          // gira a la derecha
      )
      ..lineTo(w * 0.48, h * 0.46);  // palo horizontal
    canvas.drawPath(stem, paint);

    // Primer chevron >
    final p1 = Path()
      ..moveTo(w * 0.26, h * 0.24)
      ..lineTo(w * 0.52, h * 0.50)
      ..lineTo(w * 0.26, h * 0.76);

    // Segundo chevron >
    final p2 = Path()
      ..moveTo(w * 0.52, h * 0.24)
      ..lineTo(w * 0.78, h * 0.50)
      ..lineTo(w * 0.52, h * 0.76);

    canvas.drawPath(p1, paint);
    canvas.drawPath(p2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Colita triangular de las burbujas (estilo WhatsApp)
class _TailPainter extends CustomPainter {
  final Color color;
  final bool isMe;

  const _TailPainter({required this.color, required this.isMe});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    if (isMe) {
      // Triángulo en esquina superior-derecha (mensajes enviados)
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(0, size.height);
    } else {
      // Triángulo en esquina superior-izquierda (mensajes recibidos)
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
