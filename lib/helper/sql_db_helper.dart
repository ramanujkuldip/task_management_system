import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_management_kuldeep_practical/model/task_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get db async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String dbPath = await getDatabasesPath();
    String path = join(dbPath, "task_management.db");

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) {
    return db.execute('''CREATE TABLE task_table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
    taskName TEXT NOT NULL,
    isCompleted INTEGER NOT NULL DEFAULT 0,
    description TEXT,
    createdAt int,
    priority TEXT
    )''');
  }

  Future<int> insertTask(TaskModel task) async {
    Database db = await instance.db;
    return await db.insert('task_table', task.toMap());
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    Database db = await instance.db;
    return await db.query('task_table');
  }

  Future<int> updateTask(TaskModel task) async {
    Database db = await instance.db;
    return await db.update('task_table', task.toMap(), where: 'id = ?', whereArgs: [task.id]);
  }

  Future<int> deleteTask(int id) async {
    Database db = await instance.db;
    return await db.delete('task_table', where: 'id = ?', whereArgs: [id]);
  }
}
