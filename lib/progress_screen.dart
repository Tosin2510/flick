import 'dart:async';

import 'package:flick/direction_of_toggle.dart';
import 'package:flick/send_or_receive_toggle_direction.dart';
import 'package:flick/track_files_being_transferred.dart';
import 'package:flutter/material.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});
  static bool isVisible = false;

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends  State<ProgressScreen> {
   SendOrReceiveToggleDirection activeTab = SendOrReceiveToggleDirection.received;

  List<ItemToBeTransferred> items = [];
  StreamSubscription<List<ItemToBeTransferred>>? sub;


  @override
  void initState() {
    super.initState();

    ProgressScreen.isVisible = true;
    items = TrackFilesBeingTransferred.instance.transferItem;
     sub = TrackFilesBeingTransferred.instance.transferStream.listen((updated) {
      if (mounted) setState(() => items = updated);
    });
  }

  @override
  void dispose() {
    ProgressScreen.isVisible = false;
    sub?.cancel();
    super.dispose();
  }

  List<ItemToBeTransferred> get filteredItems {
    final TransferDirection wanted = activeTab == SendOrReceiveToggleDirection.received
        ? TransferDirection.received
        : TransferDirection.sent;
    return items.where((value) => value.direction == wanted).toList();
  }

  int get totalBytes => filteredItems.fold(0, (sum, i) => sum + i.totalBytes);
  int get transferredBytes => filteredItems.fold(0, (sum, i) => sum + i.transferredBytes); 

   String byteStructure(int bytes) {
    if (bytes >= 1024 * 1024) return '${(bytes/ (1024 * 1024)).toStringAsFixed(1)}MB';
    if (bytes >= 1024) return '${(bytes/ 1024).toStringAsFixed(1)}KB';
    return '${bytes}B';
   }

   IconData iconFor(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_rounded;
    if (mimeType.startsWith('video/')) return Icons.videocam_rounded;
    if (mimeType.startsWith('audio/')) return Icons.music_note_rounded;
    if (mimeType == 'application/pdf') return Icons.picture_as_pdf_rounded;
    if (mimeType.startsWith('text/')) return Icons.text_snippet_rounded;
    if (mimeType == 'application/zip') return Icons.archive_rounded;

    if (mimeType == 'application/vnd.android.package-archive') return Icons.android_rounded;
    return Icons.insert_drive_file_rounded;
   }
   
  @override
  Widget build(BuildContext context) {
     final size = MediaQuery.of(context).size;
    final double overallProgress = totalBytes == 0 ? 0 : transferredBytes / totalBytes;
    return Scaffold(
      backgroundColor: const Color(0xFF141414),
      body: SafeArea(
         child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,

            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.maybePop(context);
                    },

                    child: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70),
                  ),

                  const SizedBox(width: 8),

                  const Text(
                    'Transferring',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  )
                ]
              ),

              const SizedBox(height: 16,),

              DirectionOfToggle(
                active: activeTab,
                onChanged: (direction) => setState(() =>  activeTab = direction),
              ),

              const SizedBox(height: 16),

              ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(10),
               child: Stack(
                children: [
                  Container(
                    height: 32,
                    color: const Color(0xFF1F1F1F)
                  ),

                  FractionallySizedBox(
                    widthFactor: overallProgress.clamp(0.0, 1.0),
                    child: Container(
                      height: 32,
                      color: const Color(0xFF258CFA)
                    )
                  ),

                  Positioned.fill(
                    child: Padding(
                      padding:  const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),

                          Text(
                            '${byteStructure(transferredBytes)}/${byteStructure(totalBytes)}', 
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            )
                          )
                        ]
                      )
                    )
                  )
                ]
               )
              ),

              const SizedBox(height: 16,),

              Flexible(
                child: filteredItems.isEmpty
                 ? Padding(
                    padding: EdgeInsets.symmetric(vertical: size.height * 0.06),
                    child: Center(
                      child: Text(
                        activeTab == SendOrReceiveToggleDirection.received
                           ? 'No files received yet'
                           : 'No files sent yet',
                        style: const TextStyle(color: Colors.white38),
                      ),
                    ),
                  )

                  : ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) => buildItemRow(filteredItems[index]), 
                    separatorBuilder: (_, _) => const SizedBox(height: 10), 
                    itemCount: filteredItems.length
                  )
              )
            ]
          )
         ),

      )
    );
  }

  Widget buildItemRow(ItemToBeTransferred item) {
    return Container(
      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12)
      ),

      child: Row(children: [
        Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF334155),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(iconFor(item.mimeType), color: Colors.white, size: 22,),
          ),
          const SizedBox(width: 12,),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    item.fileName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4,),

                Text(
                  '${byteStructure(item.totalBytes)} • ${statusLabel(item.status)}',
                  style: TextStyle(
                    color: item.status == TransferStatus.failed
                       ? Colors.redAccent
                       : Colors.white54,
                    fontSize: 12,
                  ),
                )
              ]
            )
          ),
          buildTrailing(item),
      ],)
    );
  }

  String statusLabel(TransferStatus status) {
    switch (status) {
      case TransferStatus.waiting:
        return 'Waiting';
      case TransferStatus.inProgress:
        return 'In progress';
      case TransferStatus.paused:
        return 'Paused';
      case TransferStatus.done:
        return 'Done';
      case TransferStatus.failed:
        return 'Failed';
    }
  }

  Widget buildTrailing(ItemToBeTransferred item) {
    switch (item.status) {
      case TransferStatus.inProgress:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            value: item.totalBytes == 0 ? 0.0 : item.transferredBytes / item.totalBytes,
            color: const Color(0xFF258CFA),
            backgroundColor: Colors.white12,
          ),
        );
      case TransferStatus.waiting:
        return const SizedBox(width: 24, height: 24,);
      case TransferStatus.paused:
        return OutlinedButton(
          onPressed: null,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFF258CFA)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
          ),
          child: const Text(
            'Resume',
            style: TextStyle(
              color: Color(0xFF258CFA),
              fontSize: 12
            ),
          )
        );
      case TransferStatus.done:
        if (item.mimeType.startsWith('audio/') && item.direction == TransferDirection.received) {
          return TextButton(
            onPressed: null,
            child: const Text('Play', style: TextStyle(color: Color(0xFF258CFA), fontSize: 12)),
          );
        }
        return const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 22,);
      case TransferStatus.failed:
        return const Icon(Icons.error_rounded, color: Colors.redAccent, size: 22,);
    }
  }
}