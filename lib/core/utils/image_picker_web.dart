import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_for_web/image_picker_for_web.dart';

class PickedImageData {
  final Uint8List bytes;
  final String name;

  PickedImageData({required this.bytes, required this.name});
}

Future<PickedImageData?> pickImageFile() async {
  try {
    final ImagePickerPlugin plugin = ImagePickerPlugin();
    final XFile? file = await plugin.getImageFromSource(source: ImageSource.gallery);
    if (file != null) {
      final bytes = await file.readAsBytes();
      return PickedImageData(bytes: bytes, name: file.name);
    }
  } catch (e) {
    debugPrint('image_picker_for_web error: $e');
  }
  return null;
}
