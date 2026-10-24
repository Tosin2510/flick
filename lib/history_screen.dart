import 'package:flick/direction_of_toggle.dart';
import 'package:flick/history_service.dart';
import 'package:flick/send_or_receive_toggle_direction.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:flick/track_files_being_transferred.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  SendOrReceiveToggleDirection activeTab = SendOrReceiveToggleDirection.received;
  bool isLoading = true;
  List<Map<String, dynamic>> historyList = [];
  bool selectionMethod = false;
  final Set<String> selectedItemIds = {};

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final rows = await HistoryService.instance.getAllTransferHistory();
    if (mounted) {
      setState(() {
        isLoading = false;
        historyList = rows;
      });
    }
  }

  List<Map<String, dynamic>> get rows {
    return historyList.where((r) => r['transferDirection'] == activeTab.name).toList();
  }

   String dateForm(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 
      'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Map<String, List<Map<String, dynamic>>> get groupByDate {
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final row in rows) {
      final timeStamp = row['timeStamp'] as int;
      final date = DateTime.fromMillisecondsSinceEpoch(timeStamp);
      final dateLabel = dateForm(date);
      groups.putIfAbsent(dateLabel, () => []).add(row);
    }
    return groups;
  }

  void selectionAreaState(String id) {
    setState(() {
      if (selectedItemIds.contains(id)) {
        selectedItemIds.remove(id);
      } else {
        selectedItemIds.add(id);
      }
    });
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

  String byteFormat(int bytes) {
    if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '$bytes B';
  }

  Future<void> deleteSelectedHistory() async {
    await HistoryService.instance.deleteTransferHistory(selectedItemIds.toList());
    setState(() {
      selectedItemIds.clear();
      selectionMethod = false;
    });

    await loadHistory();
  }

    Widget buildRow(Map<String, dynamic> row) {
    final String id = row['id'] as String;
    final String fileName = row['fileName'] as String;
    final String mimeType = row['mimeType'] as String;
    final int totalBytes = row['totalBytes'] as int;
    final String? savedPath = row['savedAt'] as String?;
    final String status = row['transferStatus'] as String;

    final bool fileExists = savedPath != null && (savedPath.startsWith('content://') || File(savedPath).existsSync());
    final bool isFailed = status == TransferStatus.failed.name;

    String? statusLabel;
    if (isFailed) {
      statusLabel = 'Failed';
    } else if (!fileExists) {
      statusLabel = 'File can\'t be opened here, check your device.';
    }

    Widget trailing;
    if (selectionMethod) {
      trailing = Checkbox(
        value: selectedItemIds.contains(id),
        onChanged: (_) => selectionAreaState(id),
        activeColor: const Color(0xFF258CFA),
      );
    } else if (!fileExists) {
      trailing = GestureDetector(
        onTap: () => selectionAreaState(id),
        child: const Icon(Icons.close_rounded, color: Colors.redAccent, size: 22),
      );
    } else {
      trailing = IconButton(
        onPressed: () async {
          final outcome = await OpenFile.open(savedPath);
          if (outcome.type != ResultType.done && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Could not open file: ${outcome.message}'),
              ),
            );
          }
        },
        icon: const Icon(Icons.open_in_new_rounded, color: Color(0xFF258CFA), size: 20),
      );
    }

    return GestureDetector(
      onLongPress: () {
        setState(() {
          selectionMethod = true;
          selectedItemIds.add(id);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(iconFor(mimeType), color: const Color(0xFF258CFA), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      byteFormat(totalBytes),
                      style: const TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                  ),
                  if (statusLabel != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        statusLabel,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 11),
                      ),
                    ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  Color(0xFF141414),
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
                    onTap: () => Navigator.maybePop(context),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                    )
                  )
                ]
              ),

              const SizedBox(height: 16,),
              DirectionOfToggle(
                active: activeTab,
                onChanged: (direction) {
                  setState(() {
                    activeTab = direction;
                  });
                },
                
              ),

              const SizedBox(height: 16),
              Expanded(
                child: isLoading ? const Center(child: CircularProgressIndicator(color: Color(0xFF258CFA)),) 
                : rows.isEmpty
                    ? const Center(child: Text('No history yet', style: TextStyle(color: Colors.white38))
                )
                : ListView(
                  children: groupByDate.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        ...entry.value.map((row) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: buildRow(row),
                        )),

                        const SizedBox(height: 8),
                        ]
                      );
                  }).toList()

                )
              ),
              if (selectionMethod && selectedItemIds.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton.icon(
                  onPressed: deleteSelectedHistory,
                  icon: const Icon(Icons.delete_rounded, size: 18),
                  label: Text('Delete (${selectedItemIds.length})'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF258CFA),
                    minimumSize: const Size.fromHeight(48),
                  ),
                ),
              ),
            ]
          )
        )
      )
    );
  }
}