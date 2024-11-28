import 'package:ace_routes/model/OrderTypeModel.dart';
import 'package:sqflite/sqflite.dart';

import '../databse_helper.dart';

class OrderTypeDataTable {
  static const String tableName = 'order_types';

  // Create the table
  static Future<void> onCreate(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        nm TEXT,
        abr TEXT,
        dur INTEGER,
        cap INTEGER,
        pid INTEGER,
        ctmslot INTEGER,
        eltmslot TEXT,
        val REAL,
        xid TEXT,
        upd TEXT,
        by TEXT
      )
    ''');
  }

  // Insert order type data
  static Future<void> insertOrderTypeData( OrderTypeModel orderType) async {
    final db = await DatabaseHelper().database;

    await db.insert(
      tableName,
      orderType.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all order type data
  static Future<List<OrderTypeModel>> fetchAllOrderTypes() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((map) => OrderTypeModel.fromMap(map)).toList();
  }


  //Getting Category name

  static Future<String?> gettingCategoryThroughTid(String tid) async {
    final db = await DatabaseHelper().database;

    try {
      // Query the statuses table for the given id
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        columns: ['nm'], // Fetch only the 'name' column
        where: 'id = ?', // Condition to match the ID
        whereArgs: [tid], // Pass the ID as an argument
      );

      // Return the name if it exists
      if (maps.isNotEmpty) {
        print("Fetched name for tid $tid: ${maps.first['nm']}");
        return maps.first['nm'] as String?;
      } else {
        print("No name found for pid $tid");
        return null; // ID does not exist
      }
    } catch (e) {
      print("Error fetching name for id $tid: $e");
      return null;
    }
  }


  // Clear all data
  static Future<void> clearOrderTypeData() async {
    final db = await DatabaseHelper().database;
    await db.delete(tableName);
  }
}
