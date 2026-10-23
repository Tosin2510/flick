import 'dart:async';
import 'dart:io';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';

enum NetworkDiscoveryState {idle, starting, stopping, scanning}

class NetworkDiscoveryService {

  final StreamController<List<BonsoirService>> deviceController = StreamController<List<BonsoirService>>.broadcast();
  BonsoirDiscovery? bonsoirDiscovery;
  NetworkDiscoveryState _discoveryState = NetworkDiscoveryState.idle;
  StreamSubscription<BonsoirDiscoveryEvent>? discoverySub;

  final List<BonsoirService> discoveredDevices = [];

  List<String> connectedIps = [];

  Timer? timer;

  Future<void> startDiscovery() async {
    if (_discoveryState != NetworkDiscoveryState.idle) return;
    _discoveryState = NetworkDiscoveryState.starting;
    connectedIps = await getAllLocalIps();
    discoveredDevices.clear();

    if (!deviceController.isClosed) {
      deviceController.add([]);
    }

    try {
      bonsoirDiscovery = BonsoirDiscovery(type: '_fileshare._tcp');
      discoverySub = bonsoirDiscovery!.eventStream?.listen((event) {
          handleDiscoveryEvent(event);
      });

      _discoveryState = NetworkDiscoveryState.scanning;
      await bonsoirDiscovery!.start();

      startLivenessCheck();

    } catch (e) {
      debugPrint('Error starting discovery: $e');

       await discoverySub?.cancel();
        discoverySub = null;
        bonsoirDiscovery = null;
        _discoveryState = NetworkDiscoveryState.idle;
      
    }
  }

  void handleDiscoveryEvent(BonsoirDiscoveryEvent event) {
        if(_discoveryState != NetworkDiscoveryState.scanning) return;

        final service = event.service;
        if (service == null) return;

        switch(event.type) {
          case BonsoirDiscoveryEventType.discoveryServiceFound:
          if(bonsoirDiscovery == null) return;
          break;
          
          case BonsoirDiscoveryEventType.discoveryServiceResolved:
          
          final resolvedIp = getServiceIp(service);
          if (resolvedIp != null && connectedIps.contains(resolvedIp)) return;
          discoveredDevices.removeWhere((device) => device.name == service.name);
          discoveredDevices.add(service);

          if (!deviceController.isClosed) {
            deviceController.add(List.from(discoveredDevices));
          }
          break;

          case BonsoirDiscoveryEventType.discoveryServiceLost:
          discoveredDevices.removeWhere((device) => device.name == service.name);
          if (!deviceController.isClosed) {
              deviceController.add(List.from(discoveredDevices));
          }
          break;

          default: break;
        }
  }

  Future<void> stopScanning() async {
    if (_discoveryState == NetworkDiscoveryState.idle || _discoveryState == NetworkDiscoveryState.stopping) return;

    timer?.cancel();
    timer = null;

    _discoveryState = NetworkDiscoveryState.stopping;
    try {
      await discoverySub?.cancel();
      discoverySub = null;
      if (bonsoirDiscovery != null) {
        await bonsoirDiscovery!.stop();
      }
    } catch (e) {
      debugPrint('Error stopping discovery: $e');
    } finally {
      bonsoirDiscovery = null;
      discoveredDevices.clear();
      _discoveryState = NetworkDiscoveryState.idle;
    }
  }

    void startLivenessCheck() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (_discoveryState != NetworkDiscoveryState.scanning) return;
      final snapshot = List<BonsoirService>.from(discoveredDevices);
      bool changed = false;
        for (final device in snapshot) {
          final active = await isDeviceStillAvailable(getServiceIp(device), device.port);
          if (_discoveryState != NetworkDiscoveryState.scanning) return;
          if (!active) {
            discoveredDevices.removeWhere((val) => val.name == device.name);
            debugPrint('Removed unreachable device: ${device.name}');
            changed = true;
        }
    }
    if (changed && !deviceController.isClosed) {
      deviceController.add(List.from(discoveredDevices));
    }
  });
  }

  Future<bool> isDeviceStillAvailable(String? ip, int? port) async {
    if (ip == null || port == null) return false;

    try {
      final socket = await Socket.connect(ip, port, timeout: const Duration(seconds: 3));
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }

 String? getServiceIp(BonsoirService service) {
  if (service is ResolvedBonsoirService) {
    return service.ip;
  }
  return null;
}
  
  Future<List<String>> getAllLocalIps() async {
    final ips = <String>[];
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      );
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          ips.add(addr.address);
        }
      }
    } catch (e) {
      debugPrint('Failed to get local IPs: $e');
    }
    return ips;
  }
  Future<void> dispose() async{
    await stopScanning();
    await deviceController.close();
  }
}