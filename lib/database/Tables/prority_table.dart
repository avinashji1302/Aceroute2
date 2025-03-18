import 'package:ace_routes/database/databse_helper.dart';
import 'package:sqflite/sqflite.dart';

import '../../model/priority_model.dart';

class PriorityTable {
  static const String tableName = 'priority';

  static Future<void> onCreate(Database db) async {
    await db.execute('''
    create Table $tableName(
      id TEXT PRIMARY KEY, 
      name TEXT, 
      color TEXT
    )
  ''');
  }

  // Upgrade table logic (if needed)
  static Future<void> onUpgrade(Database db) async {
    await onCreate(
        db); // Here, simply calling onCreate for upgrade as an example
  }

  // Insert Data
  static Future<void> insertPriority(Priority priority) async {
    final db = await DatabaseHelper().database;
    await db.insert(tableName, priority.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
