import '../database_helper.dart';
import '../models/dashboard_model.dart';

class DashboardRepository {
  /// جلب المبيعات اليومية لشهر وسنة معينة
  Future<List<DailySale>> getDailySales(int month, int year) async {
    final db = await DatabaseHelper.instance.database;
    final monthStr = month.toString().padLeft(2, '0');

    final result = await db.rawQuery('''
      SELECT 
        strftime('%d', created_at) as day,
        SUM(total_amount) as total
      FROM sales
      WHERE strftime('%m', created_at) = ?
        AND strftime('%Y', created_at) = ?
        AND status = 'active'
      GROUP BY day
      ORDER BY day
    ''', [monthStr, year.toString()]);

    return result.map((e) => DailySale(
      day: e['day'].toString(),
      total: (e['total'] as num).toDouble(),
    )).toList();
  }

  /// أعلى 5 منتجات مبيعًا
  Future<List<ProductSale>> getTopProducts(int month, int year) async {
    final db = await DatabaseHelper.instance.database;
    final monthStr = month.toString().padLeft(2, '0');

    final result = await db.rawQuery('''
      SELECT 
        p.name     AS product_name,
        p.category AS category,
        SUM(s.quantity) AS total_quantity
      FROM sales s
      JOIN products p ON s.product_id = p.id
      WHERE strftime('%m', s.created_at) = ?
        AND strftime('%Y', s.created_at) = ?
        AND s.status = 'active'
      GROUP BY s.product_id
      ORDER BY total_quantity DESC
      LIMIT 5
    ''', [monthStr, year.toString()]);

    return result.map((e) => ProductSale(
      productName: e['product_name'].toString(),
      category: e['category'].toString(),
      totalQuantity: (e['total_quantity'] as num).toDouble(),
    )).toList();
  }
}