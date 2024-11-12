import 'package:sqflite/sqflite.dart';
import '../../model/GTypeModel.dart';

class GTypeTable {
  static const tableName = 'gen_type';

  // Method to create the GType table
  static Future<void> onCreate(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id INTEGER PRIMARY KEY,
        name TEXT,
        typeId INTEGER,
        capacity INTEGER,
        detail TEXT,
        externalId TEXT,
        updateTimestamp TEXT,
        updatedBy TEXT
      )
    ''');
  }

  // Insert a GTypeModel into the table
  static Future<void> insertGType(Database db, GTypeModel gtype) async {
    await db.insert(
      tableName,
      gtype.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Clear existing data in the GType table
  static Future<void> clearTable(Database db) async {
    await db.delete(tableName);
  }
}
