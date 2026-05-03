import '../database_helper.dart';
import '../models/purchase_model.dart';
import '../constants.dart';

class PurchasesRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<void> addPurchase(PurchaseItem purchase) async {
    try {
      final db = await dbHelper.database;
      await db.insert('purchases', purchase.toMap());
      AppSnackbar.success("تمت إضافة المشتريات بنجاح");
    } catch (e) {
      AppSnackbar.error("فشل إضافة المشتريات: $e");
    }
  }

  Future<List<PurchaseItem>> getPurchasesForMonthWithPagination(
      int month,
      int year, {
        int limit = 20,
        int offset = 0,
      }) async {
    try {
      final db = await dbHelper.database;

      final result = await db.query(
        'purchases',
        where: 'month = ? AND year = ?',
        whereArgs: [month, year],
        orderBy: 'id DESC',
        limit: limit,
        offset: offset,
      );

      return result.map((e) => PurchaseItem.fromMap(e)).toList();
    } catch (e) {
      AppSnackbar.error("خطأ في تحميل المشتريات: $e");
      return [];
    }
  }

  Future<List<PurchaseItem>> getAllPurchases() async {
    try {
      final db = await dbHelper.database;

      final result = await db.query('purchases', orderBy: 'id DESC');

      return result.map((e) => PurchaseItem.fromMap(e)).toList();
    } catch (e) {
      AppSnackbar.error("خطأ في تحميل كل المشتريات: $e");
      return [];
    }
  }

  Future<List<PurchaseItem>> getPurchasesForMonth(int month, int year) async {
    try {
      final db = await dbHelper.database;

      final result = await db.query(
        'purchases',
        where: 'month = ? AND year = ?',
        whereArgs: [month, year],
      );

      return result.map((e) => PurchaseItem.fromMap(e)).toList();
    } catch (e) {
      AppSnackbar.error("خطأ في تحميل مشتريات الشهر: $e");
      return [];
    }
  }

  Future<bool> deletePurchase(int id) async {
    try {
      final db = await dbHelper.database;

      final result = await db.delete(
        'purchases',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (result > 0) {
        AppSnackbar.success("تم حذف المشتريات بنجاح");
        return true;
      } else {
        AppSnackbar.warning("العنصر غير موجود");
        return false;
      }
    } catch (e) {
      AppSnackbar.error("فشل حذف المشتريات: $e");
      return false;
    }
  }
}