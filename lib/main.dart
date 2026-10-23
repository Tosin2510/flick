import 'package:flick/broadcasting_service.dart';
import 'package:flick/get_device_name.dart';
import 'package:flick/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flick',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E24),
        canvasColor: const Color(0xFF1E1E24),
        colorScheme: const ColorScheme.dark(
          surface: Color(0xFF1E1E24),
        ),
      ),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final NetworkBroadcastingService networkBroadcastingService = NetworkBroadcastingService();

  @override
  void initState() {
    super.initState();
    initializeBroadcasting();
  }

  @override
  void dispose() {
    networkBroadcastingService.dispose();
    super.dispose();
  }

  Future<void> initializeBroadcasting() async {
    final deviceName = await GetDeviceName.getDeviceName();
    await networkBroadcastingService.startBroadcasting(deviceName: deviceName);
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen();
  }
}
