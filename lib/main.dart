import 'dart:async';
import 'dart:io';

import 'package:flick/broadcasting_service.dart';
import 'package:flick/get_device_name.dart';
import 'package:flick/home_screen.dart';
import 'package:flick/progress_screen.dart';
import 'package:flick/receive_service.dart';
import 'package:flick/session_of_incoming_files.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_store_plus/media_store_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isAndroid) {
    await MediaStore.ensureInitialized();
    MediaStore.appFolder = 'Flick';
  }
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const MyApp());
  });
}

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: rootNavigatorKey,
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

  final ReceiveService receiveService = ReceiveService.instance;
  StreamSubscription<SessionOfIncomingFiles>? sessionSub;

  @override
  void initState() {
    super.initState();
    initializeBroadcasting();

    receiveService.startServer();
    sessionSub = receiveService.incomingSessionStream.listen((session) {
      showIncomingDialog(session);
    });
  }

  void showIncomingDialog(SessionOfIncomingFiles session) {
     final cont = rootNavigatorKey.currentContext;
    if (cont == null) return;
    final totalSize = session.files.fold<int>(0, (sum, fil) => sum + fil.fileSize);

    showDialog(
      context: cont, 
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text('Incoming files',
        style: TextStyle(
          color: Colors.white,
        )
        ),

        content: Text(
          '${session.sendingDevice} wants to send ${session.files.length} file(s),'
          '${(totalSize / (1024 * 1024)).toStringAsFixed(1)} MB',
          style: const TextStyle(color: Colors.white70),
        ),

        actions: [
          TextButton(
             onPressed: () {
              receiveService.respondToSession(
                session.sessionId, false);
                Navigator.pop(cont);
            },
            child: const Text('Decline',
              style: TextStyle(color: Colors.redAccent),
            )
          ),

          ElevatedButton(
            onPressed: () {
              receiveService.respondToSession(
                session.sessionId, true);
                Navigator.pop(cont);

                Navigator.of(cont, rootNavigator: true).push(
                  MaterialPageRoute(
                    builder: (_) => const ProgressScreen(),
                    fullscreenDialog: true,
                  )
                );
            },
            child: const Text('Accept'),
          ),
        ],
      )
    );
  }

  @override
  void dispose() {
    sessionSub?.cancel();
    networkBroadcastingService.dispose();
    receiveService.stop();
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