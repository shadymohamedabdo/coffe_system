import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../database_helper.dart';
import '../repositories/sales_repository.dart';

class SalesController extends GetxController {
  final salesRepo = SalesRepository();
  final dbHelper = DatabaseHelper.instance;

  var products = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isSaving = false.obs;

  var selectedCategory = RxnString();
  var selectedProductId = RxnInt();
  var quantity = 1.0.obs;
  var unitPrice = 0.0.obs;
  var amount = RxnDouble();
  var unitLabel = "وحدة".obs;
  var computedWeight = 0.0.obs;

  // Form key للتحقق من صحة الإدخال
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
    } catch (e) {
      debugPrint("Error loading products: $e");
    } finally {
      isLoading(false);
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

  void updateProduct(int? id) {
    selectedProductId.value = id;
    if (id != null) {
      final p = products.firstWhere((p) => p['id'] == id);
      unitPrice.value = (p['price'] as num).toDouble();
      _recalculateWeightFromAmount(); // إعادة حساب الوزن إذا كان هناك مبلغ مدخل
    }
  }

  // دالة موحدة لإعادة حساب الوزن من المبلغ (إن وُجد)
  void _recalculateWeightFromAmount() {
    if (unitPrice.value > 0 && amount.value != null && amount.value! > 0) {
      computedWeight.value = amount.value! / unitPrice.value;
      quantity.value = computedWeight.value;
    } else {
      computedWeight.value = 0.0;
    }
  }

  // التحقق من صحة المبلغ المدخل (أكبر من صفر)
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
    // التحقق من صحة النموذج قبل الحفظ
    if (!formKey.currentState!.validate()) return;

    if (selectedProductId.value == null) {
      AppSnackbar.warning("برجاء اختيار المنتج أولاً");
      return;
    }

    isSaving(true);
    double finalQuantity = (amount.value != null) ? (amount.value! / unitPrice.value) : quantity.value;

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
}