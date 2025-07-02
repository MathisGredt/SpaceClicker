import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/resource_model.dart';

class DatabaseService {
  late Database db;

  Future<void> initDb() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = '${documentsDirectory.path}/clicker.db';

    db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE resources (
            id INTEGER PRIMARY KEY,
            drones INTEGER,
            totalCollected INTEGER
          )
        ''');
      },
    );

    final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM resources'));

    if (count == 0) {
      await db.insert('resources', Resource(energy: 0, drones: 0, totalCollected: 0).toMap());
    }
  }

  Future<Resource?> loadData() async {
    final data = await db.query('resources', limit: 1);
    if (data.isNotEmpty) {
      return Resource.fromMap(data[0]);
    }
    return null;
  }

  Future<void> saveData(Resource resource) async {
    await db.update('resources', resource.toMap(), where: 'id = ?', whereArgs: [1]);
  }

  Future<void> closeDb() async {
    await db.close();
  }
}