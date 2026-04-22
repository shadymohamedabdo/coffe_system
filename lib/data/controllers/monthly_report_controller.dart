import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/reports_repository.dart';
import '../repositories/purchases_repository.dart';
import '../models/purchase_model.dart';

class MonthlyReportController extends GetxController {
  final ReportsRepository _repo = ReportsRepository();
  final PurchasesRepository _purchasesRepo = PurchasesRepository();

  var isLoading = true.obs;
  var errorMessage = "".obs;
  var salesData = <Map<String, dynamic>>[].obs;
  var purchases = <PurchaseItem>[].obs;
  var totalSales = 0.0.obs;
  var totalPurchaseCost = 0.0.obs;
  var netProfit = 0.0.obs;

  var showAddPurchaseForm = false.obs;
  final productNameCtrl = TextEditingController();
  final quantityCtrl = TextEditingController();

  // ✅ متغيرات الفئة والوحدة
  var selectedCategory = 'بن'.obs;
  var selectedUnit = 'كيلو'.obs;
  final List<String> categories = ['بن', 'مشروب', 'أكل سريع'];

  final costPerUnitCtrl = TextEditingController();

  // تحديث الوحدة تلقائياً عند تغيير الفئة
  void updateUnitFromCategory(String category) {
    switch (category) {
      case 'بن':
        selectedUnit.value = 'كيلو';
        break;
      case 'مشروب':
        selectedUnit.value = 'كوب';
        break;
      case 'أكل سريع':
        selectedUnit.value = 'قطعة';
        break;
      default:
        selectedUnit.value = 'قطعة';
    }
  }
  @override
  void onClose() {
    productNameCtrl.dispose();
    quantityCtrl.dispose();
    costPerUnitCtrl.dispose();
    super.onClose();
  }
  @override
  void onInit() {
    super.onInit();
    loadReport();
    ever(selectedCategory, (cat) => updateUnitFromCategory(cat));
  }

  Future<void> loadReport() async {
    try {
      isLoading(true);
      errorMessage("");
      final now = DateTime.now();
      final sales = await _repo.getMonthlyReport(now.month, now.year);
      salesData.assignAll(sales);

      totalSales.value = salesData.fold(
        0.0,
            (sum, item) => sum + (item['total_amount'] as num).toDouble(),
      );

      await loadPurchases(now.month, now.year);
      calculateNetProfit();
    } catch (e) {
      errorMessage("حدث خطأ أثناء تحميل البيانات: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadPurchases(int month, int year) async {
    purchases.value = await _purchasesRepo.getPurchasesForMonth(month, year);
    totalPurchaseCost.value = purchases.fold(0.0, (sum, p) => sum + p.totalCost);
  }

  void calculateNetProfit() {
    netProfit.value = totalSales.value - totalPurchaseCost.value;
  }

  Future<void> addPurchase() async {
    if (productNameCtrl.text.isEmpty ||
        quantityCtrl.text.isEmpty ||
        costPerUnitCtrl.text.isEmpty) {
      Get.snackbar("خطأ", "يرجى ملء جميع الحقول", backgroundColor: Colors.red[100]);
      return;
    }

    final now = DateTime.now();
    final purchase = PurchaseItem(
      productName: productNameCtrl.text,
      quantity: double.tryParse(quantityCtrl.text) ?? 0,
      unit: selectedUnit.value, // استخدام الوحدة المختارة
      costPerUnit: double.tryParse(costPerUnitCtrl.text) ?? 0,
      month: now.month,
      year: now.year,
    );

    await _purchasesRepo.addPurchase(purchase);
    clearForm();
    showAddPurchaseForm.value = false;
    await loadReport();
    Get.snackbar("تم", "تمت إضافة المشتريات بنجاح", backgroundColor: Colors.green[100]);
  }

  void clearForm() {
    productNameCtrl.clear();
    quantityCtrl.clear();
    costPerUnitCtrl.clear();
    selectedCategory.value = 'بن';
  }
}