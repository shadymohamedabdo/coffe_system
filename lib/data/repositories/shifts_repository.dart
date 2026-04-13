import '../database_helper.dart';

class ShiftsRepository {
  final dbHelper = DatabaseHelper.instance;

  // جلب الشيفت المفتوح حالياً
  Future<Map<String, dynamic>?> getOpenShift() async {
    final db = await dbHelper.database;
    final result = await db.query(
      'shifts',
      where: 'is_open = ?',
      whereArgs: [1],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  // فتح شيفت جديد مع تسجيل وقت الفتح بدقة
  Future<void> openShift(String type) async {
    final db = await dbHelper.database;
    final open = await getOpenShift();
    if (open != null) return; // منع فتح شيفت لو فيه واحد مفتوح أصلاً

    await db.insert('shifts', {
      'type': type,
      'date': DateTime.now().toIso8601String(),
      'is_open': 1
    });
  }

  // قفل الشيفت
  Future<void> closeShift(int id) async {
    final db = await dbHelper.database;
    await db.update(
        'shifts',
        {'is_open': 0},
        where: 'id = ?',
        whereArgs: [id]
    );
  }

  // جلب كل الشيفتات السابقة (مرتبة من الأحدث)
  Future<List<Map<String, dynamic>>> getAllShifts() async {
    final db = await dbHelper.database;
    return await db.query('shifts', orderBy: 'id DESC');
  }
}