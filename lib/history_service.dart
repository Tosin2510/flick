import 'dart:core';

import 'package:flick/track_files_being_transferred.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HistoryService {
  HistoryService._internal();

  static final HistoryService instance = HistoryService._internal();

   Database? database;

   Future<Database> get _db async {
    if (database != null) return database!;
    final path = join(await getDatabasesPath(), 'flick_history.db');
    // I am making use of open database here.
    database = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
            await db.execute(
              '''
              Create table flick_history(
              id TEXT PRIMARY KEY,
              fileName TEXT,
              mimeType TEXT,
              totalBytes INTEGER,
              transferDirection TEXT,
              transferStatus TEXT,
              savedAt TEXT,
              timeStamp INTEGER)
              '''
            );
          },
        );
        return database!;
      }

      Future<void> shareRecord(ItemToBeTransferred item) async {
         final db = await _db;
         await db.insert(
           'flick_history',
           {
             'id': item.fileId,
             'fileName': item.fileName,
             'mimeType': item.mimeType,
             'totalBytes': item.totalBytes,
             'transferDirection': item.direction.name,
             'transferStatus': item.status.name,
             'savedAt': item.savedPath,
             'timeStamp': DateTime.now().millisecondsSinceEpoch,
           },

           conflictAlgorithm: ConflictAlgorithm.replace,
         );
      }

    Future<List<Map<String, dynamic>>> getAllTransferHistory() async {
      final db = await _db;
      final List<Map<String, dynamic>> maps = await db.query('flick_history', orderBy: 'timeStamp DESC');
      return maps;
    }

    Future<void> deleteTransferHistory(List<String> ids) async {
      final db = await _db;
      await db.delete(
        'flick_history',
        where: 'id IN (${List.filled(ids.length, '?').join(',')})',
        whereArgs: ids,
      );
    }
}