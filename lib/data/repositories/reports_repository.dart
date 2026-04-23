import '../database_helper.dart';

class ReportsRepository {
  final dbHelper = DatabaseHelper.instance;

  /// 1. التقرير الشهري المجمع
  /// يعرض إجمالي مبيعات كل منتج على حدة خلال شهر وسنة محددين
  Future<List<Map<String, dynamic>>> getMonthlyReport(int month, int year) async {
    final db = await DatabaseHelper.instance.database;
    final monthStr = month.toString().padLeft(2, '0');

    final result = await db.rawQuery('''
    SELECT 
      p.name AS product_name,
      p.unit AS unit,
      SUM(s.quantity) AS total_quantity,
      SUM(s.total_amount) AS total_amount
    FROM sales s
    JOIN products p ON s.product_id = p.id
    WHERE strftime('%m', s.created_at) = ?
      AND strftime('%Y', s.created_at) = ?
      AND s.status = 'active'
    GROUP BY s.product_id
  ''', [monthStr, year.toString()]);

    return result;
  }
  // في ReportsRepository
  Future<List<Map<String, dynamic>>> getShiftReportPaginated(
      int shiftId, {
        int limit = 20,
        int offset = 0,
      }) async {
    final db = await dbHelper.database;
    final result = await db.rawQuery('''
    SELECT 
      s.id,
      p.name AS product_name,
      s.quantity,
      p.unit,
      s.quantity * s.unit_price AS total_amount,
      u.name AS employee_name,
      s.status,
      s.created_at
    FROM sales s
    JOIN products p ON s.product_id = p.id
    LEFT JOIN users u ON s.user_id = u.id
    WHERE s.shift_id = ? AND s.status != 'deleted'
    ORDER BY s.created_at DESC
    LIMIT ? OFFSET ?
  ''', [shiftId, limit, offset]);

    return result;
  }

// هل تريد الاحتفاظ بالدالة القديمة getShiftReport؟
// يمكنك إما تعديلها لتستخدم الـ Pagination أيضاً، أو إبقاءها كما هي لاستخدامات أخرى.

  /// 2. تقرير تفصيلي لشفت معين
  /// يعرض كل عملية بيع تمت في الشفت مع اسم الموظف والمنتج وحالة العملية
  Future<List<Map<String, dynamic>>> getShiftReport(int shiftId) async {
    final db = await dbHelper.database;

    return await db.rawQuery('''
      SELECT 
        s.id,
        u.name AS employee_name,
        p.name AS product_name,
        p.unit AS unit,              -- 👈 ضفنا دي عشان تظهر "كوب" أو "كيلو"
        s.quantity AS quantity,      -- 👈 غيرنا الاسم لـ quantity عشان يطابق الشاشة
        s.unit_price,
        s.total_amount,
        s.status,
        s.created_at
      FROM sales s
      JOIN users u ON s.user_id = u.id
      JOIN products p ON s.product_id = p.id
      WHERE s.shift_id = ? 
      ORDER BY s.id DESC
    ''', [shiftId]);
  }  /// 3. تحديث حالة العملية (إلغاء أو تفعيل)
  /// تستخدم لتغيير حالة البيع من active إلى cancelled والعكس
  Future<void> updateSaleStatus(int saleId, String newStatus) async {
    final db = await dbHelper.database;
    await db.update(
      'sales',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [saleId],
    );
  }

  /// 4. جلب إجمالي مبيعات اليوم (اختياري - مفيد للوحة التحكم)
  Future<double> getTodayTotalSales() async {
    final db = await dbHelper.database;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total 
      FROM sales 
      WHERE date(created_at) = date(?) AND status = 'active'
    ''', [today]);

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}