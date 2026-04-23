import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../database_helper.dart';
import '../repositories/sales_repository.dart';
import '../repositories/purchases_repository.dart';
import '../repositories/reports_repository.dart';

class SalesController extends GetxController {
  final salesRepo = SalesRepository();
  final dbHelper = DatabaseHelper.instance;
  final _purchasesRepo = PurchasesRepository();
  final _reportsRepo = ReportsRepository();

  var products = <Map<String, dynamic>>[].obs;
  var availableProducts = <Map<String, dynamic>>[].obs; // ✅ المنتجات المتاحة فقط
  var isLoading = true.obs;
  var isSaving = false.obs;

  var selectedCategory = RxnString();
  var selectedProductId = RxnInt();
  var quantity = 1.0.obs;
  var unitPrice = 0.0.obs;
  var amount = RxnDouble();
  var unitLabel = "وحدة".obs;
  var computedWeight = 0.0.obs;
  var productRemainingMap = <int, double>{}.obs; // ✅ رصيد كل منتج

  final formKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    isLoading(true);
    try {
      final db = await dbHelper.database;
      final result = await db.query('products');
      products.assignAll(result);
      await _loadRemainingBalances();
      // ✅ تصفية المنتجات المتاحة (الرصيد > 0)
      availableProducts.assignAll(
          products.where((p) => (productRemainingMap[p['id']] ?? 0) > 0).toList()
      );
    } catch (e) {
      debugPrint("Error loading products: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> _loadRemainingBalances() async {
    try {
      final now = DateTime.now();
      final purchases = await _purchasesRepo.getPurchasesForMonth(now.month, now.year);
      final sales = await _reportsRepo.getMonthlySalesGroupedByProduct(now.month, now.year);

      Map<String, double> purchasedQuantity = {};
      for (var p in purchases) {
        purchasedQuantity[p.productName] = (purchasedQuantity[p.productName] ?? 0) + p.quantity;
      }

      for (var product in products) {
        double purchased = purchasedQuantity[product['name']] ?? 0;
        double sold = sales[product['name']] ?? 0;
        double remaining = purchased - sold;
        productRemainingMap[product['id']] = remaining > 0 ? remaining : 0.0;
      }
    } catch (e) {
      print("خطأ في حساب الأرصدة: $e");
    }
  }

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

  Future<void> updateProduct(int? id) async {
    selectedProductId.value = id;
    if (id != null) {
      final p = products.firstWhere((p) => p['id'] == id);
      unitPrice.value = (p['price'] as num).toDouble();
      _recalculateWeightFromAmount();

      // التحقق من الرصيد (في حالة اختيار منتج)
      double remaining = productRemainingMap[id] ?? 0;
      if (remaining <= 0) {
        AppSnackbar.warning("هذا المنتج غير متوفر حالياً (الكمية المستوردة قد انتهت)");
        selectedProductId.value = null;
      }
    }
  }

  void _recalculateWeightFromAmount() {
    if (unitPrice.value > 0 && amount.value != null && amount.value! > 0) {
      computedWeight.value = amount.value! / unitPrice.value;
      quantity.value = computedWeight.value;
    } else {
      computedWeight.value = 0.0;
    }
  }

  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return "أدخل رقماً صحيحاً";
    if (parsed <= 0) return "المبلغ يجب أن يكون أكبر من صفر";
    return null;
  }

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

  double get currentTotal => amount.value ?? (quantity.value * unitPrice.value);

  Future<void> saveSale(int userId) async {
    if (!formKey.currentState!.validate()) return;
    if (selectedProductId.value == null) {
      AppSnackbar.warning("برجاء اختيار المنتج أولاً");
      return;
    }

    // التحقق من الرصيد مرة أخرى قبل الحفظ
    double remaining = productRemainingMap[selectedProductId.value] ?? 0;
    if (remaining <= 0) {
      AppSnackbar.warning("المنتج غير متوفر (الرصيد صفر)");
      return;
    }

    double finalQuantity = (amount.value != null) ? (amount.value! / unitPrice.value) : quantity.value;
    if (finalQuantity > remaining) {
      AppSnackbar.warning("الكمية المطلوبة تتجاوز الرصيد المتوفر (${remaining.toStringAsFixed(2)})");
      return;
    }

    isSaving(true);
    try {
      int? activeShiftId = await dbHelper.getOpenShiftId();
      if (activeShiftId == null) {
        AppSnackbar.error("لا توجد وردية مفتوحة حالياً");
        return;
      }

      await salesRepo.addSale(
        shiftId: activeShiftId,
        userId: userId,
        productId: selectedProductId.value!,
        quantity: finalQuantity,
        unitPrice: unitPrice.value,
        totalAmount: currentTotal,
      );

      AppSnackbar.success("تم تسجيل العملية بنجاح");
      resetFields();
      DatabaseHelper.notifySalesChanged();
      await loadProducts(); // ✅ إعادة تحميل المنتجات والقائمة المتاحة
    } catch (e) {
      AppSnackbar.error("حدث خطأ أثناء الحفظ");
    } finally {
      isSaving(false);
    }
  }

  void resetFields() {
    selectedProductId.value = null;
    amount.value = null;
    computedWeight.value = 0.0;
    if (selectedCategory.value == 'بن') {
      quantity.value = 0.125;
    } else {
      quantity.value = 1.0;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}