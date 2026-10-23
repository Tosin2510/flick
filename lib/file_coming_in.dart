class FileComingIn {
  final String fileId;
  final String fileName;
  final String mimeType;
  final int fileSize;

  const FileComingIn({
    required this.fileId,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
  });

  factory FileComingIn.fromJson(Map<String, dynamic> json) {
    return FileComingIn(
      fileId: json['fileId'] as String,
      fileName: json['fileName'] as String,
      mimeType: json['mimeType'] as String,
      fileSize: json['fileSize'] as int,
    );
  }
}