import '../database_helper.dart';

class SalesRepository {
  final dbHelper = DatabaseHelper.instance;

  // ===== إضافة عملية بيع =====
// داخل كلاس SalesRepository في ملف sales_repository.dart

  Future<void> addSale({
    required int shiftId,
    required int userId,
    required int productId,
    required double quantity,
    required double unitPrice,
    required double totalAmount, // ✅ السطر ده هو اللي ناقصك
    String status = 'active',
    String? createdAt,
  }) async {
    final db = await dbHelper.database;

    await db.insert('sales', {
      'shift_id': shiftId,
      'user_id': userId,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_amount': totalAmount, // ✅ استخدام القيمة الممرة
      'status': status,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    });

    DatabaseHelper.notifySalesChanged();
  }

  // ===== تحديث حالة البيع =====
  Future<void> updateSaleStatus(int saleId, String newStatus) async {
    final db = await dbHelper.database;

    await db.update(
      'sales',
      {'status': newStatus},
      where: 'id = ?',
      whereArgs: [saleId],
    );

    DatabaseHelper.notifySalesChanged();
  }

  // ===== جلب مبيعات شيفت (محسنة) =====
  Future<List<Map<String, dynamic>>> getSalesByShift(int shiftId) async {
    final db = await dbHelper.database;

    return await db.rawQuery('''
      SELECT 
        sales.*,
        products.name as product_name
      FROM sales
      LEFT JOIN products ON products.id = sales.product_id
      WHERE sales.shift_id = ?
      ORDER BY sales.id DESC
    ''', [shiftId]);
  }

  // ===== جلب كل المبيعات =====
  Future<List<Map<String, dynamic>>> getAllSales() async {
    final db = await dbHelper.database;

    return await db.rawQuery('''
      SELECT 
        sales.*,
        products.name as product_name
      FROM sales
      LEFT JOIN products ON products.id = sales.product_id
      ORDER BY sales.id DESC
    ''');
  }
}