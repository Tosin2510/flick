import 'dart:io';
import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetDeviceName {

  static Future<String> suffix() async {
    final prefs = await SharedPreferences.getInstance();

    String? suffixVal = prefs.getString('device_suffix');
    if (suffixVal == null) {
      suffixVal = generateRandomFourLettersFromAlphabet();
      await prefs.setString('device_suffix', suffixVal);
    }
    return suffixVal;
  }

  static Future<String> getDeviceName() async {
    final name = await baseName();
    final suffixVal = await suffix();
    return '$name ($suffixVal)';
  }

  static Future<String> baseName() async {
    final deviceInfoPlugin = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final information = await deviceInfoPlugin.androidInfo;
        return information.model;
      } else if (Platform.isIOS) {
        final info = await deviceInfoPlugin.iosInfo;
        return info.name;
      }
    } catch (e) {
      return 'Unknown Device';
    }
    return 'Unknown Device';
  }

  static String generateRandomFourLettersFromAlphabet() {
    const character = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(4, (_) => character[rand.nextInt(character.length)]).join();
  }
}