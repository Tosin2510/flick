import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flick/build_empty_state.dart';
import 'package:flick/build_tile_when_devices_are_available.dart';
import 'package:flick/discovery_service.dart';
import 'package:flutter/material.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class ListOfDiscoveredDevices extends StatefulWidget {

  final List<PlatformFile> selectedGeneralFiles;
  final List<AssetEntity> selectedMediaFiles;
  final VoidCallback onComplete;

  const ListOfDiscoveredDevices({
    super.key,
    required this.selectedGeneralFiles,
    required this.selectedMediaFiles,
    required this.onComplete,
  });

  @override
  State<ListOfDiscoveredDevices> createState() => _ListOfDiscoveredDevicesState();
}

class _ListOfDiscoveredDevicesState extends State<ListOfDiscoveredDevices> with SingleTickerProviderStateMixin {
  final NetworkDiscoveryService networkDiscoveryService = NetworkDiscoveryService();

  List<BonsoirService> devices = [];

  bool isRefreshing = false;

  StreamSubscription<List<BonsoirService>>? deviceSub;
  late AnimationController refreshAnimation;

  bool isSending = false;

  Future<void> startScanning() async {
    await deviceSub?.cancel();
    deviceSub= networkDiscoveryService.deviceStream.listen((foundDevices){
      if(mounted) setState(() => devices = foundDevices);
    });
    await networkDiscoveryService.startDiscovery();
    if(mounted) setState(() {});
  }

  Future<void> refreshList() async {
    if(isRefreshing) return;
    setState(() => isRefreshing = true);
    refreshAnimation.repeat(reverse: true);
     setState(() => devices = []);
      await networkDiscoveryService.stopDiscovery();
      await startScanning();
      await Future.delayed(const Duration(seconds: 3));

      if (mounted) {
        refreshAnimation.stop();
        refreshAnimation.reset();
        if(mounted) setState(() => isRefreshing = false);
      }
  }

  Future<void> handleTapping(BonsoirService device) async {
    final String? address = networkDiscoveryService.getServiceIp(device);
     if (address == null) {
      return;
    }

    if(isSending) return;
    setState(() {
      isSending = true;
    });

    debugPrint('Selected ${device.name} at $address');

    if (mounted) {
      setState(() {
        isSending = false;
      });
    }
  }

  @override
  void initState() {
    refreshAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    super.initState();
    startScanning();
  }

  @override
  void dispose() { 
    refreshAnimation.dispose();
    deviceSub?.cancel();
    networkDiscoveryService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final sizeOfContainer = size.width * 0.6;
    final bool isScanning = networkDiscoveryService.isScanning;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size.width * 0.06),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: size.width * 0.1,
              height: size.height * 0.005,
              margin: EdgeInsets.symmetric(vertical: size.height * 0.015),
              decoration: BoxDecoration(
                color:Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(size.height* 0.003),
              ),
            )
          ),

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Nearby Devices",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: sizeOfContainer * 0.14,
                  fontWeight: FontWeight.bold,
                )
              ),

              const Spacer(),
              GestureDetector(
                onTap: () {
                  refreshList();
                },

                child: SizedBox(
                  width: sizeOfContainer * 0.14,
                  height: sizeOfContainer * 0.14,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (isRefreshing)
                      CircularProgressIndicator(strokeWidth: 2,
                        color: const Color(0xFF258CFA).withValues(alpha: 0.4),
                      ),

                      RotationTransition(
                        turns: refreshAnimation,
                        child: Icon(
                          Icons.refresh_rounded,
                          color: isRefreshing ? const Color(0xFF258CFA): Colors.white54,
                          size: sizeOfContainer * 0.1,
                        )
                      )
                    ]
                  )
                )
              )
            ] 
          ),
          
          SizedBox(height: sizeOfContainer * 0.03),

          Text(
            'Devices with the app opened will appear here.',
            style: TextStyle(
              color: const Color(0xFCCCCCCC),
              fontSize: sizeOfContainer * 0.075,
              fontWeight: FontWeight.w400,
            )
          ),
          
          SizedBox(height: sizeOfContainer * 0.060),

          SizedBox(
            height: size.height * 0.45,
            child: devices.isEmpty ? BuildEmptyState(
              sizeOfContainer: sizeOfContainer, 
              isScanning: isScanning,                    
            )
            : ListView.separated(
              itemBuilder: (context, value) {
                final device = devices[value];
                  return BuildTileWhenDevicesAreAvailable(
                    sizeOfContainer: sizeOfContainer,
                    device: device,
                    onTap:() {
                      handleTapping(device);
                    }
                  );
              },

              separatorBuilder: (_, _) {
                return SizedBox(height: sizeOfContainer * 0.04);
              }, 
              itemCount: devices.length,
            )
          )
        ]
      )
    );
  }
}