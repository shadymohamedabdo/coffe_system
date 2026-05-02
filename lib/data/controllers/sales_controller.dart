import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../database_helper.dart';
import '../repositories/sales_repository.dart';
import '../repositories/purchases_repository.dart';
import '../repositories/reports_repository.dart';
import '../models/product_model.dart';

class SalesController extends GetxController {
  // 🔹 Repositories
  final salesRepo = SalesRepository();
  final dbHelper = DatabaseHelper.instance;
  final _purchasesRepo = PurchasesRepository();
  final _reportsRepo = ReportsRepository();

  // 🔹 المنتجات (دلوقتي Product مش Map)
  var products = <Product>[].obs;

  // 🔹 المنتجات المتاحة للبيع فقط
  var availableProducts = <Product>[].obs;

  // 🔹 حالات
  var isLoading = true.obs;
  var isSaving = false.obs;

  // 🔹 الاختيارات
  var selectedCategory = RxnString();
  var selectedProductId = RxnInt();

  // 🔹 القيم
  var quantity = 1.0.obs;
  var unitPrice = 0.0.obs;
  var amount = RxnDouble();
  var unitLabel = "وحدة".obs;
  var computedWeight = 0.0.obs;

  // 🔹 الرصيد لكل منتج
  var productRemainingMap = <int, double>{}.obs;

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // ================= تحميل المنتجات =================
  Future<void> loadProducts() async {
    isLoading(true);
    try {
      final db = await dbHelper.database;

      final result = await db.query('products');

      // 🔥 تحويل Map → Product
      products.assignAll(
        result.map((e) => Product.fromMap(e)).toList(),
      );

      await _loadRemainingBalances();
      _filterAvailableProducts();
    } catch (e) {
      AppSnackbar.error("خطأ في تحميل المنتجات: $e");
    } finally {
      isLoading(false);
    }
  }

  // ================= حساب الرصيد =================
  Future<void> _loadRemainingBalances() async {
    try {
      final now = DateTime.now();

      final purchases =
      await _purchasesRepo.getPurchasesForMonth(now.month, now.year);

      final sales =
      await _reportsRepo.getMonthlySalesGroupedByProduct(
          now.month, now.year);

      Map<String, double> purchasedQuantity = {};

      for (var p in purchases) {
        purchasedQuantity[p.productName] =
            (purchasedQuantity[p.productName] ?? 0) + p.quantity;
      }

      for (var product in products) {
        double purchased = purchasedQuantity[product.name] ?? 0;
        double sold = sales[product.name] ?? 0;

        double remaining = purchased - sold;

        productRemainingMap[product.id!] =
        remaining > 0 ? remaining : 0.0;
      }
    } catch (e) {
      AppSnackbar.error("خطأ في حساب الأرصدة: $e");
    }
  }

  // ================= فلترة المنتجات =================
  void _filterAvailableProducts() {
    availableProducts.assignAll(
      products.where(
            (p) => (productRemainingMap[p.id] ?? 0) > 0,
      ).toList(),
    );
  }

  // ================= تغيير الكاتيجوري =================
  void onCategoryChanged(String? val) {
    selectedCategory.value = val;

    selectedProductId.value = null;
    amount.value = null;
    unitPrice.value = 0.0;
    computedWeight.value = 0.0;

    if (val == 'بن') {
      unitLabel.value = "كيلو";
      quantity.value = 0.125;
    } else {
      unitLabel.value = val == 'مشروب' ? "كوب" : "قطعة";
      quantity.value = 1.0;
    }
  }

  // ================= اختيار المنتج =================
  Future<void> updateProduct(int? id) async {
    selectedProductId.value = id;
    amount.value = null;

    if (id != null) {
      final p = products.firstWhere((p) => p.id == id);

      unitPrice.value = p.price;

      double remaining = productRemainingMap[id] ?? 0;

      if (remaining <= 0) {
        AppSnackbar.warning("هذا المنتج نفذ من المخزن");
        selectedProductId.value = null;
      }
    }
  }

  // ================= حساب الوزن =================
  void updateAmountAndWeight(String value) {
    final amountValue = double.tryParse(value);

    if (amountValue != null && amountValue > 0 && unitPrice.value > 0) {
      amount.value = amountValue;
      computedWeight.value = amountValue / unitPrice.value;
      quantity.value = computedWeight.value;
    } else {
      amount.value = null;
      computedWeight.value = 0.0;
    }
  }

  double get currentTotal =>
      amount.value ?? (quantity.value * unitPrice.value);

  // ================= Validation =================
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) return null;

    final parsed = double.tryParse(value);
    if (parsed == null) return "أدخل رقم صحيح";
    if (parsed <= 0) return "لازم يكون أكبر من صفر";

    return null;
  }

  // ================= حفظ البيع =================
  Future<void> saveSale(int userId) async {
    if (!formKey.currentState!.validate()) return;

    if (selectedProductId.value == null) {
      AppSnackbar.warning("اختار المنتج");
      return;
    }

    double remaining =
        productRemainingMap[selectedProductId.value] ?? 0;

    double finalQuantity = (amount.value != null)
        ? (amount.value! / unitPrice.value)
        : quantity.value;

    if (finalQuantity > remaining) {
      AppSnackbar.warning("الكمية أكبر من المتاح");
      return;
    }

    isSaving(true);

    try {
      int? shiftId = await dbHelper.getOpenShiftId();

      if (shiftId == null) {
        AppSnackbar.error("مفيش شيفت مفتوح");
        return;
      }

      await salesRepo.addSale(
        shiftId: shiftId,
        userId: userId,
        productId: selectedProductId.value!,
        quantity: finalQuantity,
        unitPrice: unitPrice.value,
        totalAmount: currentTotal,
      );

      AppSnackbar.success("تم الحفظ");

      resetFields();
      await loadProducts();
      DatabaseHelper.notifySalesChanged();
    } catch (e) {
      AppSnackbar.error("حصل خطأ");
    } finally {
      isSaving(false);
    }
  }

  // ================= Reset =================
  void resetFields() {
    selectedProductId.value = null;
    amount.value = null;
    computedWeight.value = 0.0;

    quantity.value =
    (selectedCategory.value == 'بن') ? 0.125 : 1.0;
  }
}