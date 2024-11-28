import 'package:ace_routes/controller/event_controller.dart';
import 'package:ace_routes/database/databse_helper.dart';
import 'package:ace_routes/model/event_model.dart';
import 'package:sqflite/sqflite.dart';

class EventTable {
  static const String tableName = 'events';

  // Create the events table
  static Future<void> onCreate(Database db) async {
    await db.execute('''
      CREATE TABLE $tableName (
        id TEXT PRIMARY KEY,
        cid TEXT,
        start_date TEXT,
        etm TEXT,
        end_date TEXT,
        name TEXT,
        wkf TEXT,
        alt TEXT,
        po TEXT,
        inv TEXT,
        tid TEXT,
        pid TEXT,
        rid TEXT,
        ridcmt TEXT,
        detail TEXT,
        lid TEXT,
        cntid TEXT,
        flg TEXT,
        est TEXT,
        lst TEXT,
        ctid TEXT,
        ctpnm TEXT,
        ltpnm TEXT,
        cnm TEXT,
        address TEXT,
        geo TEXT,
        cntnm TEXT,
        tel TEXT,
        ordfld1 TEXT,
        ttid TEXT,
        cfrm TEXT,
        cprt TEXT,
        xid TEXT,
        cxid TEXT,
        tz TEXT,
        zip TEXT,
        fmeta TEXT,
        cimg TEXT,
        caud TEXT,
        csig TEXT,
        cdoc TEXT,
        cnot TEXT,
        dur TEXT,
        val TEXT,
        rgn TEXT,
        upd TEXT,
        "by" TEXT,
        znid TEXT
      )
    ''');
  }

  // Upgrade logic for the events table
  static Future<void> onUpgrade(Database db) async {
    await onCreate(db); // Re-create the table if upgrading
  }

  // Insert event into the events table
  static Future<void> insertEvent(Event event) async {
    final db = await DatabaseHelper().database;
    fetchEvents();
    await db.insert(
      tableName,
      event.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all events
  static Future<List<Event>> fetchEvents() async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => Event.fromJson(maps[i]));
  }

  // Fetch event by ID
  static Future<Event?> fetchEventById(String id) async {
    final db = await DatabaseHelper().database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?', // SQL WHERE clause
      whereArgs: [id], // Arguments for the WHERE clause
    );

    // If data exists, return the first record as an Event object
    if (maps.isNotEmpty) {
      return Event.fromJson(maps.first);
    }

    // If no data found, return null
    return null;
  }


  // Clear all events
  static Future<void> clearEvents() async {
    final db = await DatabaseHelper().database;
    await db.delete(tableName);
  }
}
