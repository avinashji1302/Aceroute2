import 'package:ace_routes/database/databse_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/orderPartsModel.dart';

class GetOrderPartTable {
  static const String tableName = 'orderPart_data';

  // Create the OrderData table
  static Future<void> onCreate(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        oid TEXT,
        tid TEXT,
        sku TEXT,
        qty TEXT,
        upd TEXT,
        by TEXT
      )
    ''');
  }

  // Insert data into the order_data table
  static Future<void> insertData(OrderParts orderData) async {
    final db = await DatabaseHelper().database;
    await db.insert(
      tableName,
      orderData.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all data from the order_data table
  static Future<List<OrderParts>> fetchData() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => OrderParts.fromMap(maps[i]));
  }


  // Clear all data from order_data table
  static Future<void> clearData() async {
    final db = await DatabaseHelper().database;
    await db.delete(tableName);
  }
}