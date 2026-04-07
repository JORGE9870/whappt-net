import 'dart:html' as html;
import 'dart:typed_data';

Future<void> pickImageBytes(void Function(Uint8List bytes) onPicked) async {
  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.click();
  input.onChange.first.then((_) {
    final file = input.files?.first;
    if (file == null) return;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoad.first.then((_) {
      final result = reader.result;
      if (result is List<int>) {
        onPicked(Uint8List.fromList(result));
      }
    });
  });
}

Future<void> pickFileBytes(
  void Function(Uint8List bytes, {required bool isImage, String? name, int? size}) onPicked,
) async {
  final input = html.FileUploadInputElement()..accept = 'image/*,application/pdf,.pdf,.doc,.docx,.xls,.xlsx,.txt';
  input.click();
  input.onChange.first.then((_) {
    final file = input.files?.first;
    if (file == null) return;
    final isImage = file.type.startsWith('image/');
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoad.first.then((_) {
      final result = reader.result;
      if (result is List<int>) {
        onPicked(Uint8List.fromList(result), isImage: isImage, name: file.name, size: file.size);
      }
    });
  });
}

Future<void> pickContactPhotoBytes(void Function(Uint8List bytes) onPicked) async {
  final input = html.FileUploadInputElement()..accept = 'image/*';
  input.click();
  input.onChange.first.then((_) {
    final file = input.files?.first;
    if (file == null) return;
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);
    reader.onLoad.first.then((_) {
      final result = reader.result;
      if (result is List<int>) {
        onPicked(Uint8List.fromList(result));
      }
    });
  });
}

Future<void> downloadNamedBytes({required String fileName, required List<int> bytes}) async {
  final blob = html.Blob([bytes]);
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..setAttribute('download', fileName)
    ..click();
  html.Url.revokeObjectUrl(url);
}
