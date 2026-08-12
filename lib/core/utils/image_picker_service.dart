import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import 'image_picker_stub.dart'
    if (dart.library.html) 'image_picker_web.dart' as web_picker;

class PickedImageData {
  final Uint8List bytes;
  final String name;

  PickedImageData({required this.bytes, required this.name});
}

class ImagePickerService {
  static Future<PickedImageData?> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file != null) {
        final bytes = await file.readAsBytes();
        return PickedImageData(bytes: bytes, name: file.name);
      }
    } catch (e) {
      debugPrint('ImagePicker plugin exception: $e');
    }

    if (kIsWeb) {
      try {
        final webResult = await web_picker.pickImageFile();
        if (webResult != null) {
          return PickedImageData(bytes: webResult.bytes, name: webResult.name);
        }
      } catch (e) {
        debugPrint('Web image picker fallback error: $e');
      }
    }

    return null;
  }
}
