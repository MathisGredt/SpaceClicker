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
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'resource.db');

    _db = await openDatabase(
      path,
      version: 2, // Increment the version number
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            drones INTEGER NOT NULL,
            totalCollected INTEGER NOT NULL,
            noctilium INTEGER NOT NULL,
            ferralyte INTEGER NOT NULL,
            verdanite INTEGER NOT NULL,
            ignitium INTEGER NOT NULL,
            amarenthite INTEGER NOT NULL, -- New column
            crimsite INTEGER NOT NULL,    -- New column
            bonus REAL NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $_tableName ADD COLUMN amarenthite INTEGER NOT NULL DEFAULT 0');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN crimsite INTEGER NOT NULL DEFAULT 0');
        }
      },
    );
  }

  Future<Resource> loadData() async {
    await initDb();
    final List<Map<String, dynamic>> maps = await _db!.query(
      _tableName,
      where: 'id = ?',
      whereArgs: [1],
    );
    if (maps.isNotEmpty) {
      return Resource.fromMap(maps.first);
    } else {
      final defaultResource = Resource(
        drones: 0,
        totalCollected: 0,
        bonus: 1.0,
      );
      await _db!.insert(_tableName, defaultResource.toMap());
      return defaultResource;
    }
  }

  Future<void> saveData(Resource resource) async {
    await initDb();
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