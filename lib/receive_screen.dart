import 'package:flick/app_animation_logo.dart';
import 'package:flick/get_device_name.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({super.key});

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {

  @override
  Widget build(BuildContext context) {

    final double sizeOfContainer = MediaQuery.of(context).size.width * 0.6;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Color(0xFF1E1E24),
                  borderRadius: BorderRadius.circular(12),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.wifi_rounded, color: Color(0xFF258CFA), size: 20),
                    const SizedBox(width: 10,),
                    const Expanded(
                      child: Text(
                        'Make sure both devices are on the same Wi-Fi network to transfer files.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      )
                    )
                  ]
                )
              ),

              Expanded(
                child: Center(
                  child: FutureBuilder(
                    future: GetDeviceName.getDeviceName(), 
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const CircularProgressIndicator(color: Colors.white24);
                      }

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder<bool>(
                            future: SharedPreferences.getInstance().then((val) => val.getBool('animation_enabled') ?? true),
                            builder: (context, snapshot) {
                              return AppAnimationLogo(
                                sizeOfContainer: sizeOfContainer,
                                isPreferenceAnimation: snapshot.data ?? true,
                          );
                          }
                          ),

                          const SizedBox(height: 24),
                          const Text(
                             'Waiting to receive files',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                          ),

                          const SizedBox(height: 8,),
                          Text(
                            'Visible as "${snapshot.data}"',
                              style: const TextStyle(
                                color: Colors.white54,
                                fontSize: 13
                              ),
                            
                            textAlign: TextAlign.center,
                          )
                        ]
                      );
                    }
                  )
                )
              )
            ]
          )
        )
      )
    );
  }
}