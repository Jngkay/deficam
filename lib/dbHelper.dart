import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        synced INTEGER DEFAULT 0
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
      'synced': 0,
    });
    final isConnected = await isInternetConnected();
    if (isConnected) {
      // Attempt to sync data with Firestore
      try {
        await syncDataWithFirestore();
        print(
            'You have access to the internet.Your data is saved locally and sync in the firestore');
        // Mark the data as synced in the local database after successful sync
        await markDataAsSynced(result);
      } catch (e) {
        print('Error syncing data to Firestore: $e');
        // Handle synchronization failure if necessary
      }
    } else {
      print(
          'Your data is saved locally. You dont have access to the internet.');
    }

    return result;
  }

  // Function to check internet connection
  static Future<bool> isInternetConnected() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<void> syncDataWithFirestore() async {
    final isConnected = await isInternetConnected();

    if (isConnected) {
      final unsyncedData = await getUnsyncedDataFromSQLite();

      for (var data in unsyncedData) {
        try {
          // Add the data to Firestore and get the document reference
          var documentRerference = await FirebaseFirestore.instance
              .collection('imageClassificationData')
              .add(data);

         // String imagePath = data['imagePath'];
         // File imageFile = File(imagePath);

        //  String imageName = 'image_${data['id']}.jpg';
         // Reference storageReference =
          //    FirebaseStorage.instance.ref().child(imageName);
              
         // await storageReference.putFile(imageFile);
         // String downloadURL = await storageReference.getDownloadURL();

         // data['imageURL'] = downloadURL;

          // Update the synced field in the Firestore document to 1
          await documentRerference.update({'synced': 1});

          // Mark the data as synced in the local database
          await markDataAsSynced(data['id']);
         // imageFile.deleteSync();

          //This is to check that data has been successfully synced
          print('Data synced successfully: ${data['id']}');
        } catch (e) {
          print('Error syncing data to Firestore: $e');
        }
      }
    }
  }

  static Future<List<Map<String, dynamic>>> getUnsyncedDataFromSQLite() async {
    final db = await database;
    final List<Map<String, dynamic>> unsyncedData = await db!.query(
      'classification_result',
      where: 'synced = ?',
      whereArgs: [0],
    );
    return unsyncedData;
  }

  static Future<void> markDataAsSynced(int id) async {
    final db = await database;
    await db!.update(
      'classification_result',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
