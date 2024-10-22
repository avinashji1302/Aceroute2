import 'dart:async';
import 'package:ace_routes/model/login_model.dart';
import 'package:ace_routes/model/login_model/version_model.dart';
import 'package:ace_routes/model/token_get_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {

      // Create the login_response table
    await db.execute('''
    CREATE TABLE login_response (
      nsp TEXT,
      url TEXT,
      subkey TEXT,
      UNIQUE(nsp, url)  // Add a unique constraint on nsp and url
    )
  ''');



    await db.execute('''
      CREATE TABLE api_data (
        requestId INTEGER PRIMARY KEY,
        responderName TEXT,
        geoLocation TEXT,
        nspId TEXT,
        gpsSync INTEGER,
        locationChange INTEGER,
        shiftDateLock INTEGER,
        shiftError INTEGER,
        endValue INTEGER,
        speed INTEGER,
        multiLeg INTEGER,
        uiConfig TEXT,
        token TEXT
      )
    ''');

    //---------------verison api table --------------------
    // Create the api_version table
    await db.execute('''
    CREATE TABLE api_version(
      success TEXT,
      id TEXT,
      UNIQUE(id)  // Add a unique constraint on nsp and url
    )
  ''');

    //---------------version APi table ends here----------------

    //--------------------login Credetial API Table ------------------

   
    //--------------------login Credetial API end here Table ------------------
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE api_version (
        success TEXT,
        id TEXT,
        UNIQUE(id)  // Add a unique constraint on nsp and url
      )
    ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE login_response (
        nsp TEXT,
        url TEXT,
        subkey TEXT,
        UNIQUE(nsp, url)  // Add a unique constraint on nsp and url
      )
    ''');
    }
  }

  // Insert data into the database
  Future<void> insertData(TokenApiReponse response) async {
    final db = await database;
    await db.insert(
      'api_data',
      response.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all data from the database
  Future<List<TokenApiReponse>> fetchData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('api_data');

    return List.generate(maps.length, (i) {
      return TokenApiReponse.fromMap(maps[i]);
    });
  }

  // Clear all data
  Future<void> clearData() async {
    final db = await database;
    await db.delete('api_data');
  }

  //----------------------------------------Version API ----------------------------------------

// Insert version data into api_version table
  Future<void> insertVersionData(VersionModel version) async {
    clearVersionData();
    final db = await database;
    await db.insert(
      'api_version',
      version.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch all API version data
  Future<List<VersionModel>> fetchVersionData() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('api_version');

    return List.generate(maps.length, (i) {
      return VersionModel.fromJson(maps[i]);
    });
  }

  // Clear all api_version data
  Future<void> clearVersionData() async {
    final db = await database;
    await db.delete('api_version');
  }

//--------------------------------------- login Response here-----------------

  // Insert LoginResponse data into the database
  Future<void> insertLoginResponse(LoginResponse loginResponse) async {
    clearLoginResponse();
    final db = await database;
    await db.insert(
      'login_response',
      loginResponse.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch LoginResponse data from the database
  Future<List<LoginResponse>> fetchLoginResponses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('login_response');

    return List.generate(maps.length, (i) {
      return LoginResponse.fromMap(maps[i]);
    });
  }

  // Clear all version data from the login_repsonse table
  Future<void> clearLoginResponse() async {
    final db = await database;
    await db.delete('login_response');
  }
}
