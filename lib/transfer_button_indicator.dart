import 'dart:async';
import 'package:flick/progress_screen.dart';
import 'package:flick/track_files_being_transferred.dart';
import 'package:flutter/material.dart';
import 'package:flick/main.dart';

class TransferButtonIndicator extends StatefulWidget {
   const TransferButtonIndicator({super.key,});

  @override
  State<TransferButtonIndicator> createState() => _TransferButtonIndicatorState();
}

class _TransferButtonIndicatorState extends State<TransferButtonIndicator> with SingleTickerProviderStateMixin {
  List<ItemToBeTransferred> transferItems = [];
  StreamSubscription<List<ItemToBeTransferred>>? _sub;

  @override
  void initState() {
  super.initState();
  transferItems = TrackFilesBeingTransferred.instance.transferItem;
  _sub = TrackFilesBeingTransferred.instance.transferStream.listen((items) {
    if (mounted) {
      setState(() => transferItems = items);
    }
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get hasActiveTransfers {
    return transferItems.any((item) => item.status == TransferStatus.inProgress || item.status == TransferStatus.waiting);
  }

  double get _transferProgress {
     final activeTransfers = transferItems.where((val) => val.status == TransferStatus.inProgress || val.status == TransferStatus.inProgress || val.status == TransferStatus.waiting,);
    if (activeTransfers.isEmpty) return 0;
    final totalStuff = activeTransfers.fold<int>(0, (sum, val) => sum + val.totalBytes);
    final completed = activeTransfers.fold<int>(0, (sum, val) => sum + val.transferredBytes);
    return totalStuff == 0? 0 : completed / totalStuff;
  }

  @override
  Widget build(BuildContext context) {
    if (!hasActiveTransfers || ProgressScreen.isVisible) {
      return const SizedBox.shrink();
    }

    return Positioned(
      right: 16,
      bottom: 24,
      child: GestureDetector(
        onTap: () {
          rootNavigatorKey.currentState?.push(
            MaterialPageRoute(
              builder: (_) => const ProgressScreen(),
              fullscreenDialog: true,
            ),
          );
        },

        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F1F),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 8,
              )        
            ]
          ),

          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  value: _transferProgress,
                  strokeWidth : 3,
                  color: const Color(0xFF258CFA),
                  backgroundColor: Colors.white12,
                )
              ),
              const Icon(
                Icons.upload_rounded,
                color: Colors.white, size: 20
              )
            ]
          )
        )
      )
    );
  }
}