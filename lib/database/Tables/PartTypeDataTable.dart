
import 'package:ace_routes/database/databse_helper.dart';
import 'package:ace_routes/model/Ptype.dart';
import 'package:sqflite/sqflite.dart';

class PartTypeDataTable {
  static const String tableName = 'part_type';

  // Create the table
  static Future<void> onCreate(Database db) async {

    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        name TEXT,
        detail TEXT,
        unitPrice TEXT,
        unit TEXT,
        updatedBy TEXT,
        updatedDate TEXT
      )
    ''');
  }

  // Upgrade table logic (if needed)
  static Future<void> onUpgrade(Database db) async {
    await onCreate(db); // Here, simply calling onCreate for upgrade as an example
  }

  // Insert part type data into part_type table
  static Future<void> insertPartTypeData(PartTypeDataModel partTypeData) async {
    final db = await DatabaseHelper().database;
    await clearPartTypeData(); // Clear existing data before inserting new one
    await db.insert(
      tableName,
      partTypeData.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all part type data
  static Future<List<PartTypeDataModel>> fetchPartTypeData() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => PartTypeDataModel.fromJson(maps[i]));
  }

  // Clear all part type data from the part_type table
  static Future<void> clearPartTypeData() async {
    final db = await DatabaseHelper().database;
    await db.delete(tableName);
  }
}
