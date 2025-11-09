import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../Modele/redacteur.dart';

class DatabaseManager {
  static final DatabaseManager instance = DatabaseManager._privateConstructor();
  static Database? _database;

  DatabaseManager._privateConstructor();

  static const _databaseName = "RedacteursDB.db";
  static const _databaseVersion = 1;
  static const table = 'redacteurs';

  static const columnId = 'id';
  static const columnName = 'nom';
  static const columnPrenom = 'prenom';
  static const columnEmail = 'email';


  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initialisation();
    return _database!;
  }


  Future<Database> _initialisation() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }


  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $table (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnName TEXT NOT NULL,  
        $columnPrenom TEXT NOT NULL,
        $columnEmail TEXT NOT NULL
      )
    ''');
  }


  Future<int> insertRedacteur(Redacteur redacteur) async {
    final db = await database;
    return await db.insert(table, redacteur.toMap());
  }


  Future<List<Redacteur>> getAllRedacteurs() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(table);


    return List.generate(maps.length, (i) {
      return Redacteur.fromMap(maps[i]);
    });
  }

  Future<int> updateRedacteur(Redacteur redacteur) async {
    final db = await database;
    return await db.update(
      table,
      redacteur.toMap(),
      where: '$columnId = ?',
      whereArgs: [redacteur.id],
    );
  }

  Future<int> deleteRedacteur(int id) async {
    final db = await database;
    return await db.delete(
      table,
      where: '$columnId = ?',
      whereArgs: [id],
    );
  }
}