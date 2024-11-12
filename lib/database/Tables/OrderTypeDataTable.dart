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
  static Future<void> insertOrderTypeData(Database db, OrderTypeModel orderType) async {
    await db.insert(
      tableName,
      orderType.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all order type data
  static Future<List<OrderTypeModel>> fetchAllOrderTypes(Database db) async {
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return maps.map((map) => OrderTypeModel.fromMap(map)).toList();
  }

  // Clear all data
  static Future<void> clearOrderTypeData() async {
    final db = await DatabaseHelper().database;
    await db.delete(tableName);
  }
}
