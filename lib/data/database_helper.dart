import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _db;

  DatabaseHelper._init();

  static final _salesStreamController = StreamController<void>.broadcast();
  static Stream<void> get salesStream => _salesStreamController.stream;

  static void notifySalesChanged() {
    _salesStreamController.add(null);
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
        version: 7, // حدثنا الرقم ليتناسب مع التعديلات
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure, // إضافة مهمة لتفعيل العلاقات
      ),
    );
  }

  // تفعيل الـ Foreign Keys
  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
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

    await _createDefaultAdmin(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 6) {
      // التأكد من عدم وجود العمود قبل إضافته لتجنب الأخطاء
      await db.execute("ALTER TABLE sales ADD COLUMN status TEXT DEFAULT 'active'");
    }
    if (oldVersion < 7) {
      await db.execute("ALTER TABLE products ADD COLUMN cost_price REAL DEFAULT 0");
      // تم مسح سطر التحديث الخاطئ لـ total_amount لأنه موجود بالفعل في onCreate
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