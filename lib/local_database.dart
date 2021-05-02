import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  Database? _database;
  DatabaseHelper._();
  static final DatabaseHelper db = DatabaseHelper._();
  Future<Database?> get database async {
    if (_database != null && _database!.isOpen) {
      return _database;
    } else {
      _database = await connectDatabase();
    }
    return _database;
  }
  set setDatabase(Database db){
    _database= db;
  }
  Future<Database?>connectDatabase()async {
    return await openDatabase("db_foods2.db",version: 1,onOpen: _onOpenDB,onCreate: _onCreateDB,);
  }
  void _onOpenDB(Database db) async{
    await db.execute("PRAGMA foreign_keys=ON");
  }
  void _onCreateDB(Database db, int versionDB) async{
    await db.execute("CREATE TABLE IF NOT EXISTS foods(idLocal INTEGER PRIMARY KEY, idServer Number ,name Text, calories Real);");
  }
  static Future<void> deleteDatabase(String path) =>
    databaseFactory.deleteDatabase(path);
}
