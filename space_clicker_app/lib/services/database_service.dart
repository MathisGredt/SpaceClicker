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
        CREATE TABLE $_tableName (
          id INTEGER PRIMARY KEY,
          noctiliumDrones INTEGER NOT NULL DEFAULT 0,
          verdaniteDrones INTEGER NOT NULL DEFAULT 0,
          ignitiumDrones INTEGER NOT NULL DEFAULT 0,
          amarenthiteDrills INTEGER NOT NULL DEFAULT 0,
          crimsiteDrills INTEGER NOT NULL DEFAULT 0,
          ferralyteDrills INTEGER NOT NULL DEFAULT 0,
          totalCollected INTEGER NOT NULL,
          noctilium INTEGER NOT NULL,
          ferralyte INTEGER NOT NULL,
          verdanite INTEGER NOT NULL,
          ignitium INTEGER NOT NULL,
          amarenthite INTEGER NOT NULL,
          crimsite INTEGER NOT NULL,
          bonus REAL NOT NULL
        )
      ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE $_tableName ADD COLUMN amarenthiteDrills INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN crimsiteDrills INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN ferralyteDrills INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN amarenthite INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN crimsite INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN ferralyte INTEGER NOT NULL DEFAULT 0');
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