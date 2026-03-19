import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/models.dart';

class DatabaseService {
  static Database? _database;
  static const String _dbName = 'baby_logger.db';
  static const int _dbVersion = 1;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _dbName);
    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE babies (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        birthDate INTEGER NOT NULL,
        avatarPath TEXT,
        createdAt INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE records (
        id TEXT PRIMARY KEY,
        babyId TEXT NOT NULL,
        type INTEGER NOT NULL,
        time INTEGER NOT NULL,
        data TEXT,
        note TEXT,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (babyId) REFERENCES babies (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE reminders (
        id TEXT PRIMARY KEY,
        babyId TEXT NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        recordType INTEGER NOT NULL,
        weekdays TEXT,
        hour INTEGER NOT NULL,
        minute INTEGER NOT NULL,
        enabled INTEGER NOT NULL DEFAULT 1,
        createdAt INTEGER NOT NULL,
        FOREIGN KEY (babyId) REFERENCES babies (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('CREATE INDEX idx_records_babyId ON records (babyId)');
    await db.execute('CREATE INDEX idx_records_time ON records (time)');
    await db.execute('CREATE INDEX idx_reminders_babyId ON reminders (babyId)');
  }

  // Baby CRUD
  Future<List<Baby>> getBabies() async {
    final db = await database;
    final maps = await db.query('babies', orderBy: 'createdAt DESC');
    return maps.map((map) => Baby.fromMap(map)).toList();
  }

  Future<Baby?> getBaby(String id) async {
    final db = await database;
    final maps = await db.query('babies', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Baby.fromMap(maps.first);
  }

  Future<void> insertBaby(Baby baby) async {
    final db = await database;
    await db.insert('babies', baby.toMap());
  }

  Future<void> updateBaby(Baby baby) async {
    final db = await database;
    await db.update('babies', baby.toMap(), where: 'id = ?', whereArgs: [baby.id]);
  }

  Future<void> deleteBaby(String id) async {
    final db = await database;
    await db.delete('babies', where: 'id = ?', whereArgs: [id]);
    await db.delete('records', where: 'babyId = ?', whereArgs: [id]);
    await db.delete('reminders', where: 'babyId = ?', whereArgs: [id]);
  }

  // Record CRUD
  Future<List<Record>> getRecords(String babyId, {DateTime? date}) async {
    final db = await database;
    String where = 'babyId = ?';
    List<dynamic> whereArgs = [babyId];

    if (date != null) {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      where += ' AND time >= ? AND time < ?';
      whereArgs.addAll([startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);
    }

    final maps = await db.query(
      'records',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'time DESC',
    );
    return maps.map((map) => Record.fromMap(map)).toList();
  }

  Future<List<Record>> getRecordsByType(String babyId, RecordType type, {int? limit}) async {
    final db = await database;
    final maps = await db.query(
      'records',
      where: 'babyId = ? AND type = ?',
      whereArgs: [babyId, type.index],
      orderBy: 'time DESC',
      limit: limit,
    );
    return maps.map((map) => Record.fromMap(map)).toList();
  }

  Future<void> insertRecord(Record record) async {
    final db = await database;
    await db.insert('records', record.toMap());
  }

  Future<void> updateRecord(Record record) async {
    final db = await database;
    await db.update('records', record.toMap(), where: 'id = ?', whereArgs: [record.id]);
  }

  Future<void> deleteRecord(String id) async {
    final db = await database;
    await db.delete('records', where: 'id = ?', whereArgs: [id]);
  }

  // Statistics
  Future<Map<String, dynamic>> getStatistics(String babyId, RecordType type, DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count, AVG(time) as avgTime
      FROM records
      WHERE babyId = ? AND type = ? AND time >= ? AND time <= ?
    ''', [babyId, type.index, start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);

    if (result.isEmpty) return {'count': 0};

    final records = await db.query(
      'records',
      where: 'babyId = ? AND type = ? AND time >= ? AND time <= ?',
      whereArgs: [babyId, type.index, start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );

    return {
      'count': result.first['count'],
      'records': records.map((map) => Record.fromMap(map)).toList(),
    };
  }

  // Reminder CRUD
  Future<List<Reminder>> getReminders(String babyId) async {
    final db = await database;
    final maps = await db.query(
      'reminders',
      where: 'babyId = ?',
      whereArgs: [babyId],
      orderBy: 'hour ASC, minute ASC',
    );
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<void> insertReminder(Reminder reminder) async {
    final db = await database;
    await db.insert('reminders', reminder.toMap());
  }

  Future<void> updateReminder(Reminder reminder) async {
    final db = await database;
    await db.update('reminders', reminder.toMap(), where: 'id = ?', whereArgs: [reminder.id]);
  }

  Future<void> deleteReminder(String id) async {
    final db = await database;
    await db.delete('reminders', where: 'id = ?', whereArgs: [id]);
  }
}
