import 'package:flick/file_coming_in.dart';

class SessionOfIncomingFiles {
  final String sessionId;
  final List<FileComingIn> files;
  final String sendingDevice;
  
  const SessionOfIncomingFiles({
    required this.sessionId,
    required this.files,
    required this.sendingDevice
  });
}