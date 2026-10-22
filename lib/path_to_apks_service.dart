import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PathToApksService {
  static const name = MethodChannel('com.example.flick/apk_path');

  static Future<List<String>> getApkPaths(String packageName) async {
    try {
      final List<dynamic>? answer = await name.invokeMethod<List<dynamic>>(
        'getApkPath',
        {'packageName': packageName},
      );

      return answer?.cast<String>() ?? [];
    } on PlatformException catch (e) {
      debugPrint('Error getting APK paths: $e');
      return [];
    } on MissingPluginException catch (e) {
      debugPrint('Error getting APK paths: $e');
      return [];
    }
  }
}