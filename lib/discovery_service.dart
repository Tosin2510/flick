import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';

enum NetworkDiscoveryState {idle, starting, stopping, scanning}

class NetworkDiscoveryService {

  final StreamController<List<BonsoirService>> deviceController = StreamController<List<BonsoirService>>.broadcast();
  BonsoirDiscovery? bonsoirDiscovery;
  NetworkDiscoveryState _discoveryState = NetworkDiscoveryState.idle;
  StreamSubscription<BonsoirDiscoveryEvent>? discoverySub;

  final List<BonsoirService> discoveredDevices = [];

  Future<void> startDiscovery() async {
    if (_discoveryState != NetworkDiscoveryState.idle) return;
    _discoveryState = NetworkDiscoveryState.starting;
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

  Future<void> dispose() async{
    await stopScanning();
    await deviceController.close();
    debugPrint('Network discovery engine tracking resources successfully released');
  }
}