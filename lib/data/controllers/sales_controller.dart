import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../database_helper.dart';
import '../repositories/sales_repository.dart';

class SalesController extends GetxController {
  final salesRepo = SalesRepository();
  final dbHelper = DatabaseHelper.instance;

  // متغيرات الحالة
  var products = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var isSaving = false.obs;

  var selectedCategory = RxnString();
  var selectedProductId = RxnInt();
  var quantity = 1.0.obs;
  var unitPrice = 0.0.obs;
  var amount = RxnDouble();
  var unitLabel = "وحدة".obs;

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
      print("Error loading products: $e");
    } finally {
      isLoading(false);
    }
  }

  // التعديل هنا: استخدام المسميات العربية لتطابق شاشة إضافة المنتجات
  void onCategoryChanged(String? val) {
    selectedCategory.value = val;
    selectedProductId.value = null;
    amount.value = null;
    unitPrice.value = 0.0;

    if (val == 'بن') {
      unitLabel.value = "كيلو";
      quantity.value = 0.125;
    } else if (val == 'مشروب') {
      unitLabel.value = "كوب";
      quantity.value = 1.0;
    } else {
      unitLabel.value = "قطعة/وحدة";
      quantity.value = 1.0;
    }
  }

  void updateProduct(int? id) {
    selectedProductId.value = id;
    if (id != null) {
      // البحث عن المنتج في القائمة المحملة لجلب سعره
      final p = products.firstWhere((p) => p['id'] == id);
      unitPrice.value = (p['price'] as num).toDouble();
    }
  }

  double get currentTotal => amount.value ?? (quantity.value * unitPrice.value);

  Future<void> saveSale(int userId) async {
    if (selectedProductId.value == null) {
      Get.snackbar("تنبيه", "برجاء اختيار المنتج أولاً", backgroundColor: Colors.orange[100]);
      return;
    }

    isSaving(true);

    double finalQuantity = (amount.value != null) ? (amount.value! / unitPrice.value) : quantity.value;

    try {
      // جلب ID الوردية المفتوحة
      int? activeShiftId = await dbHelper.getOpenShiftId();

      if (activeShiftId == null) {
        Get.snackbar(
            "تنبيه",
            "لا توجد وردية مفتوحة حالياً. برجاء فتح وردية جديدة أولاً",
            backgroundColor: Colors.red[100],
            colorText: Colors.black
        );
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

      Get.snackbar("نجاح", "تم تسجيل العملية في الوردية رقم $activeShiftId", backgroundColor: Colors.green[100]);
      resetFields();
      DatabaseHelper.notifySalesChanged();

    } catch (e) {
      Get.snackbar("خطأ", "حدث خطأ أثناء الحفظ: $e");
    } finally {
      isSaving(false);
    }
  }

  void resetFields() {
    selectedProductId.value = null;
    amount.value = null;
    if (selectedCategory.value == 'بن') {
      quantity.value = 0.125;
    } else {
      quantity.value = 1.0;
    }
  }
}