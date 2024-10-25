import 'dart:async';
import 'package:ace_routes/database/Tables/api_data_table.dart';
import 'package:ace_routes/database/Tables/login_response_table.dart';
import 'package:ace_routes/database/Tables/terms_data_table.dart';
import 'package:ace_routes/database/Tables/version_api_table.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ace_routes/database/Tables/event_table.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'api_data.db');
    return await openDatabase(
      path,
      version: 5, // Increment the version if you've added new tables or fields
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await Future.wait([
      ApiDataTable.onCreate(db),
      VersionApiTable.onCreate(db),
      LoginResponseTable.onCreate(db),
      TermsDataTable.onCreate(db),
      EventTable.onCreate(db) // Ensure EventTable is created
    ]);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 5) {
      await EventTable.onUpgrade(db); // Handle EventTable upgrade
    }
    // Add upgrade logic for other tables if needed
  }
}
