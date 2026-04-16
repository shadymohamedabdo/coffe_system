import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';   // أضف هذا السطر لو مش موجود

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _db;

  DatabaseHelper._init();

  // Streams للتحديث التلقائي
  static final _salesStreamController = StreamController<void>.broadcast();
  static final _shiftsStreamController = StreamController<void>.broadcast();

  static Stream<void> get salesStream => _salesStreamController.stream;
  static Stream<void> get shiftsStream => _shiftsStreamController.stream;

  static void notifySalesChanged() {
    _salesStreamController.add(null);
  }

  static void notifyShiftsChanged() {
    _shiftsStreamController.add(null);
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
        version: 8,                    // تم رفع النسخة
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      ),
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  // --- 1. فتح شيفت جديد مع تحديث تلقائي ---
  Future<void> startNewShift(String type) async {
    final db = await database;

    // قفل أي شفت مفتوح سابقًا
    await db.update(
      'shifts',
      {
        'is_open': 0,
        'end_time': DateTime.now().toIso8601String(),
      },
      where: 'is_open = ?',
      whereArgs: [1],
    );

    // فتح شيفت جديد
    await db.insert('shifts', {
      'type': type,
      'date': DateFormat('yyyy-MM-dd').format(DateTime.now()),
      'is_open': 1,
      'start_time': DateTime.now().toIso8601String(),
      'end_time': null,
    });

    // تحديث تلقائي للصفحة
    notifyShiftsChanged();
    notifySalesChanged();
  }

  // --- 2. جلب رقم الوردية المفتوحة حالياً ---
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

  // --- 3. إضافة عملية بيع مرتبطة بالوردية الحالية ---
  Future<int> insertSale(Map<String, dynamic> saleData) async {
    final db = await database;
    int? activeShiftId = await getOpenShiftId();
    if (activeShiftId == null) {
      throw Exception("لا توجد وردية مفتوحة حالياً لتسجيل البيع");
    }
    final completeData = Map<String, dynamic>.from(saleData);
    completeData['shift_id'] = activeShiftId;
    completeData['created_at'] = DateTime.now().toIso8601String();
    int id = await db.insert('sales', completeData);
    notifySalesChanged();
    return id;
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
      await db.execute("ALTER TABLE sales ADD COLUMN status TEXT DEFAULT 'active'");
    }
    if (oldVersion < 7) {
      await db.execute("ALTER TABLE products ADD COLUMN cost_price REAL DEFAULT 0");
    }
    if (oldVersion < 8) {
      // Reset كامل في حال الترقية (اختياري - احذر لو عندك بيانات مهمة)
      await db.execute('DROP TABLE IF EXISTS sales');
      await db.execute('DROP TABLE IF EXISTS shifts');
      await db.execute('DROP TABLE IF EXISTS products');
      await db.execute('DROP TABLE IF EXISTS users');
      await _createDB(db, newVersion);
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