import 'dart:async';

import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';


enum NetworkBroadcastingState {idle, broadcasting, starting, stopping}
class NetworkBroadcastingService {

  BonsoirBroadcast? bonsoirBroadcast;
  NetworkBroadcastingState _broadcastState = NetworkBroadcastingState.idle;

  NetworkBroadcastingState get broadcastState => _broadcastState;

  StreamSubscription<BonsoirBroadcastEvent>? broadcastSub;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool get isBroadcastingHappening {
    return _broadcastState == NetworkBroadcastingState.broadcasting;
  }

  Future<void> startBroadcasting({required String deviceName}) async {
    if (broadcastState != NetworkBroadcastingState.idle) return;
    _broadcastState = NetworkBroadcastingState.starting;
    _errorMessage = null;
    final BonsoirService service = BonsoirService(

      name: deviceName,
      type: '_fileshare._tcp',
      port: 58560,
      attributes: {
        'deviceName': deviceName,
        'platform': 'flutter',
      }
    );

    try {
      bonsoirBroadcast = BonsoirBroadcast(service: service);
      await bonsoirBroadcast!.initialize();
      broadcastSub = bonsoirBroadcast!.eventStream?.listen((event) {
        handleBroadcastEvent(event);
      });
      await bonsoirBroadcast!.start();
    } catch (e) {
      debugPrint('Error starting broadcast: $e');
      await handleFailureCases(e.toString());
    }
  }

  void handleBroadcastEvent(BonsoirBroadcastEvent event) {

    if (_broadcastState == NetworkBroadcastingState.idle || _broadcastState == NetworkBroadcastingState.stopping) return;

    switch(event) {
      case BonsoirBroadcastStartedEvent():
        _broadcastState = NetworkBroadcastingState.broadcasting;
        break;
      case BonsoirBroadcastStoppedEvent():
        _broadcastState = NetworkBroadcastingState.idle;
        break;
      default:
        break;
    }
  }

  Future<void> handleFailureCases(String errorMessage) async {
    _errorMessage = errorMessage;
    await broadcastSub?.cancel();

    broadcastSub = null;
    bonsoirBroadcast = null;
    _broadcastState = NetworkBroadcastingState.idle;
  }

  Future<void> stopBroadcasting() async {
    if (broadcastState == NetworkBroadcastingState.idle || broadcastState == NetworkBroadcastingState.stopping) return;

    _broadcastState = NetworkBroadcastingState.stopping;
    try{
      await broadcastSub?.cancel();
      broadcastSub = null;
      if(bonsoirBroadcast !=null) {
        await bonsoirBroadcast!.stop();
      }
    } catch(e) {
      debugPrint("Sth is stopping broadcast $e");
    } finally {
      bonsoirBroadcast = null;
      _broadcastState = NetworkBroadcastingState.idle;
    }

  }

  Future<void> dispose() async {
    await stopBroadcasting();
  }
}