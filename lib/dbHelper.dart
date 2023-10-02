import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class DBHelper {
  static Database? _database;

  static Future<Database?> get database async {
    if (_database != null) {
      return _database;
    }

    _database = await initDatabase();
    return _database;
  }

  static Future<Database> initDatabase() async {
    // Get the directory for storing the database
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'classification_database.db');

    // Open the database
    return openDatabase(path, version: 1, onCreate: _createTable);
  }

  static Future<void> _createTable(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS classification_result (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prediction TEXT,
        confidence REAL,
        imagePath TEXT,
        captureTime TEXT,
        synced BOOLEAN DEFAULT 0
      )
    ''');
  }

  static Future<int> saveResult({
    required String prediction,
    required double confidence,
    required String imagePath,
    required DateTime captureTime,
    bool synced = false,
  }) async {
    final db = await database;

    final result = await db!.insert('classification_result', {
      'prediction': prediction,
      'confidence': confidence,
      'imagePath': imagePath,
      'captureTime': captureTime.toIso8601String(),
      'synced': synced ? 1 : 0,
    });
    return result;
  }

  // Function to check internet connection
  static Future<bool> isInternetConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
}
