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
      version: 3, // Augmentez la version de la base de données
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            id INTEGER PRIMARY KEY,
            noctilium INTEGER,
            ferralyte INTEGER,
            verdanite INTEGER DEFAULT 0, -- Ajout de la colonne Verdanite
            ignitium INTEGER DEFAULT 0,  -- Ajout de la colonne Ignitium
            drones INTEGER,
            totalCollected INTEGER,
            bonus REAL DEFAULT 1.0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $_tableName ADD COLUMN bonus REAL DEFAULT 1.0');
        }
        if (oldVersion < 3) {
          await db.execute('ALTER TABLE $_tableName ADD COLUMN verdanite INTEGER DEFAULT 0');
          await db.execute('ALTER TABLE $_tableName ADD COLUMN ignitium INTEGER DEFAULT 0');
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
      await _db!.insert(_tableName, {
        'id': 1,
        'noctilium': 0,
        'ferralyte': 0,
        'verdanite': 0, // Initialisation par défaut
        'ignitium': 0,  // Initialisation par défaut
        'drones': 0,
        'totalCollected': 0,
        'bonus': 1.0,
      });
      return Resource(
        noctilium: 0,
        ferralyte: 0,
        verdanite: 0,
        ignitium: 0,
        drones: 0,
        totalCollected: 0,
        bonus: 1.0,
      );
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