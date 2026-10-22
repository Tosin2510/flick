import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class MediaPickerService {

  Future<List<AssetEntity>?> pickMediaFiles(BuildContext context) async {
    try {
      final bool hasPermission = await requestMediaPermission();
      if (!hasPermission) {
        return null;
      }

      if (!context.mounted) {
        return null;
      }

      final List<AssetEntity>? result = await AssetPicker.pickAssets(
        context,
        pickerConfig: AssetPickerConfig(
          maxAssets: 30,
          requestType: RequestType.common,
          textDelegate: EnglishAssetPickerTextDelegate(),
          themeColor: Color(0xFF258CF4),
          gridThumbnailSize: const ThumbnailSize.square(100), 
        )
      );

      if (!context.mounted) {
        return null;
      }

      return result;
    }

    catch(e) {
      return null;
    }
  }
}


Future<bool> requestMediaPermission() async {
  try {
    final PermissionState permission = await PhotoManager.requestPermissionExtend(
      requestOption: const PermissionRequestOption(
        androidPermission:AndroidPermission(
          type: RequestType.common,
          mediaLocation: true
        )
      )
    );

    return permission.hasAccess;
  } catch (e) {
    return false;
  }
}