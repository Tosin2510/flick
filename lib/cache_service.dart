import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

class CacheService {
  static Future<int> getCacheSizeInBytes() async {
    final cacheDirectory = await getTemporaryDirectory();

    int totalSize = 0;
    if (await cacheDirectory.exists()) {
      await for (final entity in cacheDirectory.list(recursive: true, followLinks: false)) {
        if (entity is File) {
        try {
          totalSize += await entity.length();
        } catch (_) {}
        }
      }
    }
    return totalSize;
  }

    static Future<void> clearCache() async {
    final cacheDir = await getTemporaryDirectory();
    if (await cacheDir.exists()) {
      await for (final entity in cacheDir.list()) {
        try {
          await entity.delete(recursive: true);
        } catch (e) {
          debugPrint('Error clearing cache: $e');
        }
      }
    }
  }

}
