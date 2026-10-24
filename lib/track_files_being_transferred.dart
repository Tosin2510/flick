import 'dart:async';

class TrackFilesBeingTransferred {
  TrackFilesBeingTransferred._internal();

  static final TrackFilesBeingTransferred instance = TrackFilesBeingTransferred._internal();

  final List<ItemToBeTransferred> transferItem = [];

  final StreamController<List<ItemToBeTransferred>> controller = StreamController<List<ItemToBeTransferred>>.broadcast();

  Stream<List<ItemToBeTransferred>> get transferStream {
    return controller.stream;
  }

  List<ItemToBeTransferred> get currentTransfers {
    return List.unmodifiable(transferItem);
  }

  void addTransferItem(ItemToBeTransferred item) {
    transferItem.add(item);
    controller.add(List.from(transferItem));
  }

  void startBrandNewTransfer() {
    transferItem.clear();
    controller.add(List.from(transferItem));
  }

  void updateProgress(String id, int transferredBytes) {
    final item = transferItem.where((val) => val.fileId == id).firstOrNull;
    if (item == null) return;
    item.transferredBytes = transferredBytes;
    item.status = TransferStatus.inProgress;
    controller.add(List.from(transferItem));
  }

  void transferPaused(String id) {
    final item = transferItem.where((val) => val.fileId == id).firstOrNull;
    if (item == null) return;
    item.status = TransferStatus.paused;
    controller.add(List.from(transferItem));
  }

  void transferFailed(String id) {
     final item = transferItem.where((val) => val.fileId == id).firstOrNull;
    if (item == null) return;
    item.status = TransferStatus.failed;
    controller.add(List.from(transferItem));
  }

  void transferDone(String id, String? savedPath) {
    final item = transferItem.where((val) => val.fileId == id).firstOrNull;
    if (item == null) return;
    item.status = TransferStatus.done;
    item.transferredBytes = item.totalBytes;
    if (savedPath != null) {
      item.savedPath = savedPath;
    }
    controller.add(List.from(transferItem));
  }
}

enum TransferStatus {waiting, inProgress, paused, done, failed}
enum TransferDirection {sent, received}

class ItemToBeTransferred {
  final String fileId;
  final String fileName;
  final String mimeType;
  final int totalBytes;
  int transferredBytes;
  TransferStatus status;

  final TransferDirection direction;
  String? savedPath;

  ItemToBeTransferred({
    required this.fileId,
    required this.fileName,
    required this.mimeType,
    required this.totalBytes,
    this.transferredBytes = 0,
    this.status = TransferStatus.waiting,
    required this.direction,
    this.savedPath,
  });
}