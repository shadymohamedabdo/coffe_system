import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _db;

  DatabaseHelper._init();

  // Streams للتحديث التلقائي
  static final _salesStreamController = StreamController<void>.broadcast();
  static final _shiftsStreamController = StreamController<void>.broadcast();

  static Stream<void> get salesStream => _salesStreamController.stream;
  static Stream<void> get shiftsStream => _shiftsStreamController.stream;

  static void notifySalesChanged() => _salesStreamController.add(null);
  static void notifyShiftsChanged() => _shiftsStreamController.add(null);
  static void disposeStreams() {
    _salesStreamController.close();
    _shiftsStreamController.close();
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB('coffee_pos.db');
    return _db!;
  }

  Future<Database> _initDB(String filePath) async {
    sqfliteFfiInit();
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 10, // رفع الإصدار إلى 10 لإضافة جدول المشتريات
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      ),
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<int?> getOpenShiftId() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'shifts',
      where: 'is_open = ?',
      whereArgs: [1],
      orderBy: 'id DESC',
      limit: 1,
    );
    if (maps.isNotEmpty) {
      return maps.first['id'] as int;
    }
    return null;
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        role TEXT,
        username TEXT UNIQUE,
        password TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        category TEXT,
        unit TEXT,
        price REAL,
        cost_price REAL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE shifts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT,
        user_name TEXT, 
        date TEXT,
        is_open INTEGER,
        start_time TEXT,
        end_time TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        quantity REAL,
        unit_price REAL,
        total_amount REAL,
        user_id INTEGER,
        shift_id INTEGER,
        status TEXT DEFAULT 'active',
        created_at TEXT,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (shift_id) REFERENCES shifts(id)
      )
    ''');

    // ✅ جدول المشتريات الجديد
    await db.execute('''
      CREATE TABLE purchases (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_name TEXT,
        quantity REAL,
        unit TEXT,
        cost_per_unit REAL,
        month INTEGER,
        year INTEGER
      )
    ''');

    await _createDefaultAdmin(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // ترقية من إصدار أقل من 9 (إضافة user_name)
    if (oldVersion < 9) {
      try {
        await db.execute("ALTER TABLE shifts ADD COLUMN user_name TEXT");
      } catch (e) {
        print("Column user_name already exists");
      }
      await db.execute("UPDATE shifts SET start_time = NULL WHERE start_time NOT LIKE '202%'");
      await db.execute("UPDATE shifts SET end_time = NULL WHERE end_time NOT LIKE '202%' AND is_open = 0");
    }

    // ترقية من إصدار أقل من 10 (إضافة جدول purchases)
    if (oldVersion < 10) {
      try {
        await db.execute('''
          CREATE TABLE purchases (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_name TEXT,
            quantity REAL,
            unit TEXT,
            cost_per_unit REAL,
            month INTEGER,
            year INTEGER
          )
        ''');
        print("✅ تم إنشاء جدول purchases بنجاح");
      } catch (e) {
        print("خطأ في إنشاء جدول purchases: $e");
      }
    }
  }

  Future<void> _createDefaultAdmin(Database db) async {
    final result = await db.query('users', where: 'username = ?', whereArgs: ['shady']);
    if (result.isEmpty) {
      await db.insert('users', {
        'name': 'شادي',
        'role': 'admin',
        'username': 'shady',
        'password': '1234',
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }
}