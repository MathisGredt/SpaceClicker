import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/resource_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;
  static const String _tableName = 'resource_save';

  Future<void> initDb() async {
    final path = join(await getDatabasesPath(), 'resource.db');
    _db = await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await db.execute('''
        CREATE TABLE resource_save (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          noctiliumDrones INTEGER NOT NULL DEFAULT 0,
          verdaniteDrones INTEGER NOT NULL DEFAULT 0,
          ignitiumDrones INTEGER NOT NULL DEFAULT 0,
          amarenthiteDrills INTEGER NOT NULL DEFAULT 0,
          crimsiteDrills INTEGER NOT NULL DEFAULT 0,
          ferralyteDrills INTEGER NOT NULL DEFAULT 0,
          totalCollected INTEGER NOT NULL DEFAULT 0,
          noctilium INTEGER NOT NULL DEFAULT 0,
          ferralyte INTEGER NOT NULL DEFAULT 0,
          verdanite INTEGER NOT NULL DEFAULT 0,
          ignitium INTEGER NOT NULL DEFAULT 0,
          amarenthite INTEGER NOT NULL DEFAULT 0,
          crimsite INTEGER NOT NULL DEFAULT 0,
          bonus REAL NOT NULL DEFAULT 1.0,
          noctiliumDroneInterval INTEGER NOT NULL DEFAULT 5,
          verdaniteDroneInterval INTEGER NOT NULL DEFAULT 5,
          ignitiumDroneInterval INTEGER NOT NULL DEFAULT 5,
          ferralyteDrillInterval INTEGER NOT NULL DEFAULT 5,
          crimsiteDrillInterval INTEGER NOT NULL DEFAULT 5,
          amarenthiteDrillInterval INTEGER NOT NULL DEFAULT 5,
          hasPaidSecondPlanet INTEGER NOT NULL DEFAULT 0,
          hasPaidThirdPlanet INTEGER NOT NULL DEFAULT 0
        );
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 5) {
          await db.execute('ALTER TABLE $_tableName ADD COLUMN noctiliumDroneInterval INTEGER NOT NULL DEFAULT 5');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN verdaniteDroneInterval INTEGER NOT NULL DEFAULT 5');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN ignitiumDroneInterval INTEGER NOT NULL DEFAULT 5');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN ferralyteDrillInterval INTEGER NOT NULL DEFAULT 5');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN crimsiteDrillInterval INTEGER NOT NULL DEFAULT 5');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN amarenthiteDrillInterval INTEGER NOT NULL DEFAULT 5');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN hasPaidSecondPlanet INTEGER DEFAULT 0');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN hasPaidThirdPlanet INTEGER DEFAULT 0');

        }
      },
    );
  }


  Future<void> insertInitialResourceIfNeeded() async {
    final count = Sqflite.firstIntValue(
      await _db!.rawQuery('SELECT COUNT(*) FROM $_tableName'),
    );

    if (count == 0) {
      await _db!.insert(_tableName, Resource(
        noctiliumDrones: 0,
        verdaniteDrones: 0,
        ignitiumDrones: 0,
        amarenthiteDrills: 0,
        crimsiteDrills: 0,
        ferralyteDrills: 0,
        totalCollected: 0,
        noctilium: 0,
        ferralyte: 0,
        verdanite: 0,
        ignitium: 0,
        amarenthite: 0,
        crimsite: 0,
        bonus: 1.0,
        noctiliumDroneInterval: 5,
        verdaniteDroneInterval: 5,
        ignitiumDroneInterval: 5,
        ferralyteDrillInterval: 5,
        crimsiteDrillInterval: 5,
        amarenthiteDrillInterval: 5,
        hasPaidSecondPlanet: false,
        hasPaidThirdPlanet: false,
      ).toMap()..['id'] = 1);
    }
  }


  Future<Resource> loadData() async {
    final List<Map<String, dynamic>> maps = await _db!.query(_tableName);
    if (maps.isNotEmpty) {
      return Resource.fromMap(maps.first);
    }
    throw Exception('No data found');
  }

  Future<void> saveData(Resource resource) async {
    await _db!.update(
      _tableName,
      resource.toMap(),
      where: 'id = ?',
      whereArgs: [1],
    );
  }

  Future<void> closeDb() async {
    await _db?.close();
    _db = null;
  }
}