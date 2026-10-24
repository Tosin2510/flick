import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flick/track_files_being_transferred.dart';
import 'package:gal/gal.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:flick/file_coming_in.dart';
import 'package:flick/session_of_incoming_files.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_multicast_lock/flutter_multicast_lock.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

enum ServerState { stopped, starting, running}
class ReceiveService {

  ReceiveService._internal();

  static final ReceiveService _instance = ReceiveService._internal();
  HttpServer? _server;

  final multicastLock = FlutterMulticastLock();
  ServerState _state = ServerState.stopped;
  ServerState get state { return _state; } 

  bool get isRunning => _state == ServerState.running;
  final Map<String, SessionOfIncomingFiles> sessions = {}; 
  final Map<String, Completer<bool>> decision = {};

  final StreamController<SessionOfIncomingFiles> controller =
     StreamController<SessionOfIncomingFiles>.broadcast();
  Stream<SessionOfIncomingFiles> get incomingSessionStream => controller.stream;

  final StreamController<String> fileReceivedController =
     StreamController<String>.broadcast();

  Future<void> startServer() async {
    if(state != ServerState.stopped) return;
    await multicastLock.acquireMulticastLock();
    _state = ServerState.starting;
    final router = Router();
    router.post('/prepare', handlePrepare);
    router.post('/upload', handleUpload);

    try {
       _server = await shelf_io.serve(
        router.call,
        '0.0.0.0',
        58560
       );

       _state = ServerState.running;
    } catch (e) {
      _state = ServerState.stopped;
      await multicastLock.releaseMulticastLock();
    }
  }

  Future<Response> handlePrepare(Request request) async {
  try{
    final String body = await request.readAsString();
    final Map<String, dynamic> json = jsonDecode(body);
    final String sessionId = json['sessionId'] as String;
    final String senderName = json['deviceName'] as String;
    final List<dynamic> filesJson = json['files'] as List<dynamic>;
   
    final List<FileComingIn> files = filesJson.
      map((a) => FileComingIn.fromJson(a as Map<String, dynamic>))
      .toList();
    final session = SessionOfIncomingFiles(
      sessionId: sessionId,
      sendingDevice: senderName,
      files: files,
    );
    sessions[sessionId] = session;

    final completer = Completer<bool>();
    decision[sessionId] = completer;
    controller.add(session);

    final bool userDecision = await completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () => false,
    );

    decision.remove(sessionId);

    if (!userDecision) {
      sessions.remove(sessionId);
    } else {
      TrackFilesBeingTransferred.instance.startBrandNewTransfer();
      for (final file in files) {
        TrackFilesBeingTransferred.instance.addTransferItem(
          ItemToBeTransferred(
            fileId: file.fileId,
            fileName: file.fileName,
            mimeType: file.mimeType,
            totalBytes: file.fileSize,
            transferredBytes: 0,
            status: TransferStatus.waiting,
            direction: TransferDirection.received,
          ),
        );
      }
    }

     return Response.ok(
      jsonEncode({
        'sessionId': sessionId,
        'status': userDecision ? 'accepted' : 'declined',
        }),
        headers: {'Content-Type': 'application/json'},
      );
  } catch(e) {
    debugPrint('Error handling /prepare: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to process prepare request'}),
      headers: {'Content-Type' : 'application/json'},
      );
  }
}

void respondToSession(String sessionId, bool accepted) {
  final completer = decision[sessionId];
  if (completer != null && !completer.isCompleted) {
    completer.complete(accepted);
  }
}

  Future<Response> handleUpload(Request request) async {
  try {
    final String? sessionId = request.url.queryParameters['sessionId'];

    final String? fileId = request.url.queryParameters['fileId'];

    if(sessionId == null || fileId == null) {
  return Response.badRequest(
    body: jsonEncode({'error' : 'Missing sessionId or fileId'}),
    );
}

final SessionOfIncomingFiles? session = sessions[sessionId];
if(session == null) {
  return Response.badRequest(
    body: jsonEncode({'error': 'Session not found'}),
    );
  }

    final FileComingIn? incomingFile = session.files
     .where((a) => a.fileId == fileId)
     .firstOrNull;
     if(incomingFile == null) {
      return Response.badRequest(
        body: jsonEncode({'error': 'File not found in session'}) 
        );
     }

     final Directory tempDir = await getTemporaryDirectory();
     final String tempDirPath = '${tempDir.path}/${incomingFile.fileName}';

     final File file = File(tempDirPath);
     final IOSink sink = file.openWrite();
     int received = 0;

     await request.read().forEach((chunk) {
      sink.add(chunk);
      received += chunk.length;
      TrackFilesBeingTransferred.instance.updateProgress(fileId, received);
     });

     await sink.close();

     String finalPath = tempDirPath;

     if (incomingFile.mimeType.startsWith('video/') || incomingFile.mimeType.startsWith('image/')) {
      saveMediaFiles(tempDirPath, incomingFile.mimeType);
     } else {
      final SaveInfo? information = await saveGeneralFileAndReturnInfo(tempDirPath, incomingFile.fileName, incomingFile.mimeType);
      if (information != null && information.isSuccessful) {
        finalPath = information.uri.toString();
      }
     }

      TrackFilesBeingTransferred.instance.transferDone(fileId, finalPath);
      fileReceivedController.add(tempDirPath);
     debugPrint('File saved: $tempDirPath');

     return Response.ok(
      jsonEncode({'status': 'received'}),
      headers: {'Content-Type' : 'application/json'},
     );
  } catch (e) {
    debugPrint('Error handling upload: $e');
    return Response.internalServerError(
      body: jsonEncode({'error': 'Failed to save file'}),
      );
  }
}

Future<void> saveMediaFiles(String filePath, String mimeType) async {
  try {
    if (mimeType.startsWith('image/')) {
      await Gal.putImage(filePath);
    }  else if (mimeType.startsWith('video/')) {
      await Gal.putVideo(filePath);
    } 
  } on GalException catch (e) {
    debugPrint(galErrorMessage(e.type));
  } 
}

String galErrorMessage(GalExceptionType exception) {
  switch(exception) {
    case GalExceptionType.accessDenied : 
      return 'You have no permission to access device\'s gallery';
    case GalExceptionType.notEnoughSpace:
      return 'Not enough storage space available';
    case GalExceptionType.notSupportedFormat:
      return 'File format is not supported';
    case GalExceptionType.unexpected:
      return 'Unexpected error occured';
  }
}

final MediaStore mediaStore = MediaStore();
Future<SaveInfo?> saveGeneralFileAndReturnInfo(String tempFilePath, String fileName, String mimeType) async {
  try {
    final DirType dirType;
    final DirName dirName;
    if (mimeType.startsWith('audio/')) {
      dirType = DirType.audio;
      dirName = DirName.music;
    }  else {
      dirType = DirType.download;
      dirName = DirName.download;
    }

    return await mediaStore.saveFile(
      tempFilePath: tempFilePath, 
      dirType: dirType, 
      dirName: dirName,
    );
  } catch (e) {
    return null;
  }
}

static ReceiveService get instance{
  return _instance;
}

Future<void> stop() async {
  await _server?.close(force: true);
  _server = null;
  sessions.clear();
  _state = ServerState.stopped;
  await multicastLock.releaseMulticastLock();
}
}