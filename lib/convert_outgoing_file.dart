import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flick/file_to_be_sent.dart';
import 'package:installed_apps/app_info.dart';
import 'package:mime/mime.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ConvertFileToBeSent {
  static int count = 0;

  static FileToBeSent fromPlatformFile(PlatformFile file) {

    final mimeType = lookupMimeType(file.name) ?? 'application/octet-stream';

    return FileToBeSent(
      fileId: 'file_${DateTime.now().millisecondsSinceEpoch}_${count++}',
      fileName: file.name,
      mimeType: mimeType,
      fileSize: file.lengthSync() ?? File(file.path!).lengthSync(),
      filePath: file.path!,
    );
  }

  static List<FileToBeSent> appFilesToBeSent(List<AppInfo> apps, List<List<String>> apkPaths ) {
    final List<FileToBeSent> result = [];

    for (int val = 0; val < apps.length; val++) {
      final paths = apkPaths[val];
      for (int pathIndex = 0; pathIndex < paths.length; pathIndex++) {

        final file = File(paths[pathIndex]);
        result.add(FileToBeSent(
          fileId: 'file_${DateTime.now().millisecondsSinceEpoch}_${count++}',
          fileName:  paths.length == 1 ? '${apps[val].name}.apk' : '${apps[val].name}_${pathIndex + 1}.apk',
          mimeType: 'application/vnd.android.package-archive',
          fileSize: file.lengthSync(),
          filePath: file.path,
        ));
      }

    }

    return result;
  }

  static Future<FileToBeSent?> fromAssetEntity(AssetEntity asset) async {
    final File? file = await asset.file;
    if (file == null) {
      return null;
    }

    final String fileName = asset.title ?? file.path.split('/').last;
    final mimeType = asset.mimeType ?? lookupMimeType(fileName) ?? 'application/octet-stream';
    final int fileSize = await file.length();

    return FileToBeSent(
      fileId: 'file_${DateTime.now().millisecondsSinceEpoch}_${count++}',
      fileName: fileName,
      mimeType: mimeType,
      fileSize: fileSize,
      filePath: file.path,
    );
  }

    static Future<List<FileToBeSent>> convertAllOutgoingFiles({
    List<PlatformFile> platformFiles = const [],
    List<AssetEntity> mediaFiles = const [],
    List<AppInfo> apps = const [],
    List<List<String>> apkPaths = const [],

  }) async {
    final List<FileToBeSent> result = [];

    result.addAll(platformFiles.map(fromPlatformFile));
    result.addAll(appFilesToBeSent(apps, apkPaths));

    for (final asset in mediaFiles) {
      final convertedFile = await fromAssetEntity(asset);
      if (convertedFile != null) {
        result.add(convertedFile);
      }
    }
    return result;
  }
}