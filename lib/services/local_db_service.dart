import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/cycle_model.dart';

class LocalDbService {
  static Database? _db;

  static Future<Database?> get database async {
    if (_db != null) return _db;
    try {
      _db = await _initDatabase();
    } catch (e) {
      // In unit/widget testing environments without sqflite native channel, return null safely
      return null;
    }
    return _db;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'womenz_local_db.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE user_profile (
            userId TEXT PRIMARY KEY,
            userName TEXT,
            cycleLength INTEGER,
            periodDuration INTEGER,
            lastSyncTimestamp TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE daily_logs (
            date TEXT PRIMARY KEY,
            flow TEXT,
            mood TEXT,
            symptoms TEXT,
            tookSupplements INTEGER,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE cycle_history (
            id TEXT PRIMARY KEY,
            startDate TEXT,
            endDate TEXT,
            durationDays INTEGER,
            flowIntensity TEXT,
            notes TEXT,
            isSynced INTEGER
          )
        ''');
      },
    );
  }

  // Save / Update User Profile locally
  static Future<void> saveUserProfile(UserCycleData data) async {
    final db = await database;
    if (db == null) return;
    await db.insert(
      'user_profile',
      {
        'userId': 'CURRENT_USER',
        'userName': data.userName,
        'cycleLength': data.cycleLength,
        'periodDuration': data.periodDuration,
        'lastSyncTimestamp': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Save / Update Daily Symptom Log locally
  static Future<void> saveDailyLog(DailyLog log) async {
    final db = await database;
    if (db == null) return;
    final dateKey = log.date.toString().split(' ')[0];
    await db.insert(
      'daily_logs',
      {
        'date': dateKey,
        'flow': log.flow ?? 'Medium',
        'mood': log.mood ?? 'Calm',
        'symptoms': log.symptoms.join(', '),
        'tookSupplements': log.tookSupplements ? 1 : 0,
        'notes': log.notes ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all Daily Logs
  static Future<List<Map<String, dynamic>>> getDailyLogs() async {
    final db = await database;
    if (db == null) return [];
    return await db.query('daily_logs', orderBy: 'date DESC');
  }

  // Save Cycle History entry locally
  static Future<void> saveHistoryEntry({
    required String id,
    required String startDate,
    required String endDate,
    required int durationDays,
    required String flowIntensity,
    required String notes,
  }) async {
    final db = await database;
    if (db == null) return;
    await db.insert(
      'cycle_history',
      {
        'id': id,
        'startDate': startDate,
        'endDate': endDate,
        'durationDays': durationDays,
        'flowIntensity': flowIntensity,
        'notes': notes,
        'isSynced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all Cycle History entries
  static Future<List<Map<String, dynamic>>> getHistoryEntries() async {
    final db = await database;
    if (db == null) return [];
    return await db.query('cycle_history', orderBy: 'startDate DESC');
  }

  // Export full SQLite Database snapshot as JSON for encrypted backup
  static Future<Map<String, dynamic>> exportFullSnapshot() async {
    final db = await database;
    if (db == null) return {'exported_at': DateTime.now().toIso8601String()};
    final profile = await db.query('user_profile');
    final logs = await db.query('daily_logs');
    final history = await db.query('cycle_history');

    return {
      'profile': profile,
      'daily_logs': logs,
      'cycle_history': history,
      'exported_at': DateTime.now().toIso8601String(),
    };
  }
}
