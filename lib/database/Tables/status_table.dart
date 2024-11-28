import 'package:sqflite/sqflite.dart';
import '../../model/Status_model_database.dart';
import '../databse_helper.dart';

class StatusTable {
  static const String tableName = 'statuses';

  // Create the statuses table
  static Future<void> onCreate(Database db) async {
    print("Creating statuses table...");
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        isGroup TEXT,
        groupSequence TEXT,
        groupId TEXT,
        sequence TEXT,
        name TEXT,
        abbreviation TEXT,
        isVisible TEXT
      )
    ''');
    print("Statuses table created successfully.");
  }

  // Upgrade the statuses table when schema changes
  static Future<void> onUpgrade(
      Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      await db.execute('DROP TABLE IF EXISTS $tableName');
      await onCreate(db);
    }
  }

  // Insert JSON data into the statuses table
  static Future<void> insertStatusList(
      List<Map<String, dynamic>> statusList) async {
    final db = await DatabaseHelper().database;
    Batch batch = db.batch();
    for (var status in statusList) {
      batch.insert(
        tableName,
        status,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit();
    // print("Data saved successfully in statuses table.");
  }

  // Fetch all statuses data
  static Future<List<Status>> fetchStatusData() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    print("Database query result: $maps");

    return List.generate(maps.length, (i) => Status.fromJson(maps[i]));
  }

  // Fetch a single name status by ID
  static Future<String?> fetchNameById(String id) async {
    final db = await DatabaseHelper().database;

    try {
      // Query the statuses table for the given id
      final List<Map<String, dynamic>> maps = await db.query(
        tableName,
        columns: ['name'], // Fetch only the 'name' column
        where: 'id = ?', // Condition to match the ID
        whereArgs: [id], // Pass the ID as an argument
      );

      // Return the name if it exists
      if (maps.isNotEmpty) {
        print("Fetched name for id $id: ${maps.first['name']}");
        return maps.first['name'] as String?;
      } else {
        print("No name found for id $id");
        return null; // ID does not exist
      }
    } catch (e) {
      print("Error fetching name for id $id: $e");
      return null;
    }
  }
}
