import '../database_helper.dart';

class ShiftsRepository {
  final dbHelper = DatabaseHelper.instance;

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

  Future<void> openShift(String type, String userName) async {
    final db = await dbHelper.database;
    final open = await getOpenShift();
    if (open != null) return;

    final now = DateTime.now();
    final isoString = now.toIso8601String();
    final dateOnly = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    await db.insert('shifts', {
      'type': type,
      'user_name': userName,
      'date': dateOnly,  // ✅ تاريخ فقط: 2026-04-22
      'start_time': isoString,
      'is_open': 1,
      'end_time': null,
    });

    print('✅ تم فتح شيفت جديد: $type بواسطة $userName في $dateOnly');
  }
// في ملف shifts_repository.dart
  Future<void> closeShift(int id) async {
    final db = await dbHelper.database;
    final now = DateTime.now().toIso8601String();

    print('🔴 جاري إغلاق الشيفت ID: $id');
    print('⏰ وقت الإغلاق: $now');

    final result = await db.update(
      'shifts',
      {
        'is_open': 0,
        'end_time': now  // تأكد من حفظ الوقت هنا
      },
      where: 'id = ?',
      whereArgs: [id],
    );

    print('✅ تم تحديث $result صف');

    // التحقق من التحديث
    final updated = await db.query('shifts', where: 'id = ?', whereArgs: [id]);
    print('📊 بعد التحديث: ${updated.first}');
  }
  Future<List<Map<String, dynamic>>> getAllShifts() async {
    final db = await dbHelper.database;
    return await db.query('shifts', orderBy: 'id DESC');
  }
}