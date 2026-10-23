class FileToBeSent {
  final String fileId;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final String filePath;

  const FileToBeSent({
    required this.fileId,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.filePath,
  });

  Map<String, dynamic> toJson() => {
    'fileId': fileId,
    'fileName': fileName,
    'mimeType': mimeType,
    'fileSize': fileSize,
    'filePath': filePath,
  };
}