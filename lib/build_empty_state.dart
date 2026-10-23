import 'package:flutter/material.dart';

class BuildEmptyState extends StatelessWidget {
  final double sizeOfContainer;
  final bool isScanning;

  const BuildEmptyState({
    super.key,
    required this.sizeOfContainer,
    required this.isScanning,
  });

  @override
  Widget build(BuildContext context) {
     return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isScanning ? Icons.wifi_find_rounded : Icons.wifi_off_rounded,
          color: Colors.white12,
          size: sizeOfContainer * 0.35,
          ),

          SizedBox(height: sizeOfContainer * 0.06,),
          Text(
            isScanning ? 'Looking for devices..': 'No devices found',
            style: TextStyle(
              color: Colors.white38,
              fontSize: sizeOfContainer * 0.09,
              fontWeight: FontWeight.w500,
            )
          ),
           SizedBox(height: sizeOfContainer * 0.02),

           Text(
            isScanning ? 'Make sure other devices have the app open' : 'Tap refresh to scan again',

            style: TextStyle(
              color: Colors.white24,
              fontSize: sizeOfContainer *0.07,
            ),

            textAlign: TextAlign.center,
          )
        ]
      )
     );
  }
}