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

  static Future<String?> getBaseApkPath(String packageName) async {
    final paths = await getApkPaths(packageName);

    return paths.isEmpty ? null : paths.first;
  }

  static Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final List<dynamic>? answer = await name.invokeMethod<List<dynamic>>('getInstalledApps');
      return (answer ?? []).map((e) => Map<String, String>.from(e as Map)).toList();
    } on PlatformException catch (e) {
      debugPrint('Error getting installed apps: $e');
      return [];
    } on MissingPluginException catch (e) {
      debugPrint('Error getting installed apps: $e');
      return [];
    }
  }
}