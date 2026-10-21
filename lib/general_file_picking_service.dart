import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class GeneralFilePickingService {
  static Future<List<PlatformFile>> pickFiles(String fileCategory) async {
    try {
      FileType fileType = FileType.any;
      if (fileCategory == "Music") {
        fileType = FileType.audio;
      } else if (fileCategory == "Files") {
        fileType = FileType.any;
      }

      List<PlatformFile> files = await FilePicker.pickFiles(
        type: fileType,
      );

      return files.where((file) => file.path != null).toList();
    }

    catch(e) {
      debugPrint("Error picking files: $e");
    }

    return [];
  }
}