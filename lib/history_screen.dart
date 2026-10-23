import 'package:flick/direction_of_toggle.dart';
import 'package:flick/send_or_receive_toggle_direction.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {

  SendOrReceiveToggleDirection activeTab = SendOrReceiveToggleDirection.received;
  bool isLoading = true;
  List<Map<String, dynamic>> historyList = [];

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    // Transfer history doesn't exist yet. Load the saved rows into historyList here later.
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get rows => historyList
      .where((r) => r['transferDirection'] == activeTab.name)
      .toList();

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

  IconData icon(String mimeType) {
    if (mimeType.startsWith('image/')) return Icons.image_rounded;
    if (mimeType.startsWith('video/')) return Icons.videocam_rounded;
    if (mimeType.startsWith('audio/')) return Icons.music_note_rounded;
    if (mimeType == 'application/vnd.android.package-archive') return Icons.android_rounded;
    return Icons.insert_drive_file_rounded;
  }

  String byteFormat(int bytes) {
    if (bytes >= 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    if (bytes >= 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '$bytes B';
  }

  Widget buildRow(Map<String, dynamic> row) {
    final String fileName = row['fileName'] as String;
    final String mimeType = row['mimeType'] as String;
    final int totalBytes = row['totalBytes'] as int;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon(mimeType), color: const Color(0xFF258CFA), size: 28),
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
              ],
            ),
          ),
        ],
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
              )

            ]
          )
        )
      )
    );
  }
}