import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

Future<void> pickImageBytes(void Function(Uint8List bytes) onPicked) async {
  final r = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
  final f = r?.files.single;
  if (f?.bytes == null) return;
  onPicked(f!.bytes!);
}

Future<void> pickFileBytes(
  void Function(Uint8List bytes, {required bool isImage, String? name, int? size}) onPicked,
) async {
  final r = await FilePicker.platform.pickFiles(withData: true);
  final f = r?.files.single;
  if (f?.bytes == null) return;
  final isImage = (f!.extension ?? '').toLowerCase().contains('jpg') ||
      (f.extension ?? '').toLowerCase().contains('jpeg') ||
      (f.extension ?? '').toLowerCase().contains('png') ||
      (f.extension ?? '').toLowerCase().contains('gif') ||
      (f.extension ?? '').toLowerCase().contains('webp');
  onPicked(f.bytes!, isImage: isImage, name: f.name, size: f.size);
}

Future<void> pickContactPhotoBytes(void Function(Uint8List bytes) onPicked) async {
  await pickImageBytes(onPicked);
}

Future<void> downloadNamedBytes({required String fileName, required List<int> bytes}) async {
  await Share.shareXFiles([
    XFile.fromData(Uint8List.fromList(bytes), name: fileName, mimeType: 'text/plain'),
  ], text: 'Exportar chat');
}
