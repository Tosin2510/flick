import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/material.dart';

class BuildTileWhenDevicesAreAvailable extends StatelessWidget{
  final BonsoirService device;
  final double sizeOfContainer;
  final VoidCallback? onTap;

  const BuildTileWhenDevicesAreAvailable({
    super.key,
    required this.device,
    required this.sizeOfContainer,
    required this.onTap

  });

  IconData deviceIcon(String platform) {
    switch(platform.toLowerCase()) {
      
      case 'android':
        return Icons.android_rounded;
      case 'ios':
        return Icons.apple_rounded;
      default:
        return Icons.phone_android_rounded;

    }
  }

  @override
  Widget build(BuildContext context) {
    final String platform = device.attributes['platform']?.toUpperCase() ?? 'UNKNOWN';
    final String version = device.attributes['version'] ?? '';

    return GestureDetector(
       onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sizeOfContainer * 0.06,
          vertical: sizeOfContainer * 0.055,
        ),

        decoration: BoxDecoration(
          color: Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(sizeOfContainer * 0.06),

          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
            width: 1,
          ),
        ),

        child: Row(
          children: [
            Container(
              width: sizeOfContainer * 0.14,
              height: sizeOfContainer * 0.14,
              decoration: BoxDecoration(
                color: Color(0xFF334155),
                borderRadius: BorderRadius.circular(sizeOfContainer * 0.04),
              ),

              child: Icon(
                deviceIcon(platform),
                color: Colors.white,
                size: sizeOfContainer * 0.09,
              )
            ),

            SizedBox(width: sizeOfContainer * 0.05,),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sizeOfContainer * 0.09,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: sizeOfContainer * 0.01,),

                  Text(
                     '#${device.port}  •  $platform${version.isNotEmpty? '  v$version': ''}',
                     style: TextStyle(
                      color: Color(0xFF9DA6B9),
                      fontSize: sizeOfContainer * 0.06,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.3
                    ),
                  )
                ]
              )
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: sizeOfContainer * 0.1,
            )
          ]
        )
      )
    );
  }
}