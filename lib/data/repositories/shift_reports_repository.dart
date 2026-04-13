import '../database_helper.dart';

class ShiftReportRepository {
  final dbHelper = DatabaseHelper.instance;

  // 📌 جلب تقرير شيفت
  Future<List<Map<String, dynamic>>> getShiftReport(int shiftId) async {
    final db = await dbHelper.database;

    return await db.rawQuery('''
      SELECT s.id,
             u.name as employee_name,
             p.name as product_name,
             s.quantity as total_quantity,
             s.unit_price,
             s.quantity * s.unit_price as total_amount,
             s.status
      FROM sales s
      JOIN users u ON s.user_id = u.id
      JOIN products p ON s.product_id = p.id
      WHERE s.shift_id = ? AND s.status = 'active'
    ''', [shiftId]);
  }

  // 📌 إلغاء عملية بيع
  Future<void> cancelSale(int saleId) async {
    final db = await dbHelper.database;
    await db.update(
      'sales',
      {'status': 'cancelled'},
      where: 'id = ?',
      whereArgs: [saleId],
    );
  }
}
