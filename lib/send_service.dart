import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flick/file_to_be_sent.dart';
import 'package:flick/track_files_being_transferred.dart';
import 'package:flutter/foundation.dart';

enum SendOutcome {accepted, rejected, failed}
class SendService {
  final Dio dio = Dio();

  Future<SendOutcome> sendFiles({
    required String targetDeviceIp,
    required String sendingDeviceName,
    required List<FileToBeSent> files,

    void Function(String fileId, double progress) ? onProgress,
  }) async {
    final String sessionId = DateTime.now().millisecondsSinceEpoch.toString();
    final String baseUrl = 'http://$targetDeviceIp:${58560}';

    TrackFilesBeingTransferred.instance.startBrandNewTransfer();

    for (final file in files) {
       TrackFilesBeingTransferred.instance.addTransferItem(
        ItemToBeTransferred(
          fileId: file.fileId, 
          fileName: file.fileName, 
          mimeType: file.mimeType, 
          totalBytes: file.fileSize, 
          direction: TransferDirection.sent,
          savedPath: file.filePath,
      )
    );
    }

    try {
      final transferResponse = await dio.post(
        '$baseUrl/prepare',
        data: {
          'sessionId': sessionId,
          'sendingDevice': sendingDeviceName,
          'files': files.map((file) => file.toJson()).toList(),
        },

        options: Options(
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 35)
        )
      );

      final transferStatus = transferResponse.data['status'] as String?;
      if (transferStatus != 'accepted') {
        for (final file in files) {
          TrackFilesBeingTransferred.instance.transferFailed(file.fileId);
        }
        return SendOutcome.rejected;
      }

      for (final file in files) {
        final fileOnDisk = File(file.filePath);
          if (!await fileOnDisk.exists()) {
          TrackFilesBeingTransferred.instance.transferFailed(file.fileId);
          continue;
        }

        await dio.post(
          '$baseUrl/upload',
          queryParameters: {
            'sessionId': sessionId,
            'fileId': file.fileId,
          },
          data: fileOnDisk.openRead(),

          options: Options(
            headers: {
             Headers.contentLengthHeader: file.fileSize,
             Headers.contentTypeHeader: 'application/octet-stream',
            }
          ),

          onSendProgress: (sent, total) {
            TrackFilesBeingTransferred.instance.updateProgress(
              file.fileId,
              sent
            );
          }
        );

        TrackFilesBeingTransferred.instance.transferDone(file.fileId, file.filePath);
      }
      
      return SendOutcome.accepted;
    } on DioException catch(e) {
      debugPrint('Send failed: ${e.message}');
      for (final file in files) {
        TrackFilesBeingTransferred.instance.transferFailed(file.fileId);
      }
      return SendOutcome.failed;
    } catch(e) {
      debugPrint('Unexpected send error: $e');
      return SendOutcome.failed;
    }
  }
}