import 'package:flick/cache_service.dart';
import 'package:flick/get_device_name.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String deviceName = '';
  String appVersion = '';
  String cacheSize = '';
  bool animationEnabled = true;

  @override
  void initState() {
    super.initState();
    loadDeviceName();
    loadInfoAbtApp();
    loadCacheSize();
    loadAnimationPreference();
  }

  Future<void> loadDeviceName() async {
    final name = await GetDeviceName.getDeviceName();
    if (mounted) {
      setState(() {
        deviceName = name;
      });
    }
  }

  Future<void> clearTransferHistory() async {
    final clear = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1E24),
          title: const Text('Clear transfer history?', style: TextStyle(color: Colors.white)),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), 
              child: const Text('CANCEL')
            ),

            TextButton(
              onPressed: () => Navigator.pop(context, true), 
              child: const Text('CLEAR')
            )
          ]
        );
      }
    );

    if (clear == true) {
      // Clear transfer history logic here
    }
  }

  Future<void> loadAnimationPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final allowed = prefs.getBool('animation_enabled') ?? true;
    if (mounted) setState(() => animationEnabled = allowed);
  }

  Future<void> setUserAnimationPreference(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('animation_enabled', val);
    setState(() {
      animationEnabled = val;
    });
  }

  Future<void> loadCacheSize() async {
    final bytes = await CacheService.getCacheSizeInBytes();
    if (mounted) {
      setState(() {
        cacheSize = bytes >= 1024 * 1024
          ? '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB'
          : '${(bytes / 1024).toStringAsFixed(2)} KB';
      });
    }
  }

  Future<void> loadInfoAbtApp() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => appVersion = '${info.version} ');
  }

  Future<void> clearCache() async {
    await CacheService.clearCache();
    await loadCacheSize();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cache cleared'),)
      );
    }
  }

  Future<void> editDeviceName() async {
    final controller = TextEditingController(text: deviceName);
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
         backgroundColor: const Color(0xFF1E1E24),
        title: const Text('Device name', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter a name',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),

          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save')
          )
        ]
      )
    );

    if (result != null) {
      await GetDeviceName.getStoredDeviceName(result);
      await loadDeviceName();

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Settings',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)
              ),

              const SizedBox(height: 24,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "General Settings",
                  style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w600, fontSize: 13,
                  ),
                )
              ),

              eachSettingsTile(
                title:'Device name',
                subtitle: deviceName,
                trailing: buttonControl(
                  'Change',
                  editDeviceName,
                )
              ),

              animationTile(
                title: 'Enable animations',
                value: animationEnabled,
                onChanged: setUserAnimationPreference,
              ),

              eachSettingsTile(
                title: 'Clear transfer history',
                trailing: buttonControl(
                  'Clear',
                  clearTransferHistory,
                )
              ),

              eachSettingsTile(
                title: 'Clear cache',
                subtitle: cacheSize,
                trailing: buttonControl(
                  'Clear',
                  clearCache,
                )
              ),

              const SizedBox(height: 24,),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  "About",
                  style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.w600, fontSize: 13,
                  ),
                ),
              ),

              eachSettingsTile(
                title: 'App Version',
                subtitle: appVersion,
              )
            ]
          )
        )
      )
    );
  }

  Widget eachSettingsTile({required String title, String? subtitle, Widget? trailing}) {

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, 
                 style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
              ),

              if (subtitle != null && subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 11)),
              )
            ]
           )
          ),

          trailing ?? const SizedBox.shrink()
        ],
      )
    );
  }

  Widget animationTile({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        children: [
          Expanded(
            child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14))
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(value: value, onChanged: onChanged, activeThumbColor: const Color(0xFF258CFA),
            )
          )
        ]
      )
    );
  }

  Widget buttonControl(String label, VoidCallback onTap) {
    return ElevatedButton(
       onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF258CFA),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style : const TextStyle(fontSize: 12, color: Colors.white)),
    );
  }
}