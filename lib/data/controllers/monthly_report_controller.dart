import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../repositories/reports_repository.dart';
import '../repositories/purchases_repository.dart';
import '../models/purchase_model.dart';

class MonthlyReportController extends GetxController {
  final ReportsRepository _repo = ReportsRepository();
  final PurchasesRepository _purchasesRepo = PurchasesRepository();

  // متغيرات الحالة
  var isLoading = true.obs;
  var errorMessage = "".obs;
  var salesData = <Map<String, dynamic>>[].obs;
  var purchases = <PurchaseItem>[].obs;
  var totalSales = 0.0.obs;
  var totalPurchaseCost = 0.0.obs;
  var netProfit = 0.0.obs;

  // بيانات الجدول المحسوبة
  var tableData = <Map<String, dynamic>>[].obs;

  // متغيرات الفلتر
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;

  // نموذج إضافة المشتريات
  var showAddPurchaseForm = false.obs;
  final productNameCtrl = TextEditingController();
  final quantityCtrl = TextEditingController();
  var selectedCategory = 'بن'.obs;
  var selectedUnit = 'كيلو'.obs;
  final List<String> categories = ['بن', 'مشروب', 'أكل سريع'];
  final costPerUnitCtrl = TextEditingController();

  // Pagination
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  var isLoadingMore = false.obs;
  final int pageSize = 20;

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

  void updateTableData() {
    final Map<String, Map<String, dynamic>> combined = {};

    // تجميع المبيعات
    for (var sale in salesData) {
      final rawName = sale['product_name'] as String;
      final normalizedName = rawName.trim().toLowerCase();
      final unit = sale['unit'] ?? '';

      if (combined.containsKey(normalizedName)) {
        combined[normalizedName]!['sold_quantity'] += sale['total_quantity'];
        combined[normalizedName]!['sales_amount'] += sale['total_amount'];
      } else {
        combined[normalizedName] = {
          'product_name': rawName,
          'sold_quantity': sale['total_quantity'],
          'sales_amount': sale['total_amount'],
          'purchased_quantity': 0.0,
          'purchase_cost': 0.0,
          'unit': unit,
        };
      }
    }

    // تجميع المشتريات
    for (var purchase in purchases) {
      final rawName = purchase.productName;
      final normalizedName = rawName.trim().toLowerCase();

      if (combined.containsKey(normalizedName)) {
        combined[normalizedName]!['purchased_quantity'] += purchase.quantity;
        combined[normalizedName]!['purchase_cost'] += purchase.totalCost;
      } else {
        combined[normalizedName] = {
          'product_name': rawName,
          'sold_quantity': 0.0,
          'sales_amount': 0.0,
          'purchased_quantity': purchase.quantity,
          'purchase_cost': purchase.totalCost,
          'unit': purchase.unit,
        };
      }
    }

    tableData.value = List<Map<String, dynamic>>.from(combined.values);
  }

  @override
  void onInit() {
    super.onInit();
    loadReport();
    ever(selectedCategory, (cat) => updateUnitFromCategory(cat));
  }

  void changeMonth(int month) {
    selectedMonth.value = month;
    loadReport();
  }

  void changeYear(int year) {
    selectedYear.value = year;
    loadReport();
  }

  Future<void> loadReport() async {
    try {
      isLoading(true);
      errorMessage("");
      final sales = await _repo.getMonthlyReport(selectedMonth.value, selectedYear.value);
      salesData.assignAll(sales);

      totalSales.value = salesData.fold(
        0.0,
            (sum, item) => sum + (item['total_amount'] as num).toDouble(),
      );

      currentPage.value = 1;
      hasMoreData.value = true;
      await loadPurchasesPage(selectedMonth.value, selectedYear.value, 1);
    } catch (e) {
      errorMessage("حدث خطأ أثناء تحميل البيانات: $e");
      AppSnackbar.error("خطأ في التحميل: $e");
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadPurchasesPage(int month, int year, int page) async {
    if (isLoadingMore.value) return;
    try {
      isLoadingMore(true);
      final offset = (page - 1) * pageSize;
      final newPurchases = await _purchasesRepo.getPurchasesForMonthWithPagination(
        month, year, limit: pageSize, offset: offset,
      );

      if (newPurchases.isEmpty) {
        hasMoreData.value = false;
      } else {
        if (page == 1) {
          purchases.assignAll(newPurchases);
        } else {
          purchases.addAll(newPurchases);
        }
        if (newPurchases.length < pageSize) hasMoreData.value = false;
      }

      updateTableData();
      totalPurchaseCost.value = purchases.fold(0.0, (sum, p) => sum + p.totalCost);
      calculateNetProfit();
    } finally {
      isLoadingMore(false);
    }
  }

  Future<void> loadNextPage() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    currentPage.value++;
    await loadPurchasesPage(selectedMonth.value, selectedYear.value, currentPage.value);
  }

  void calculateNetProfit() {
    netProfit.value = totalSales.value - totalPurchaseCost.value;
  }

  Future<void> addPurchase() async {
    if (productNameCtrl.text.isEmpty) {
      AppSnackbar.warning("يرجى إدخال اسم المنتج");
      return;
    }
    final quantity = double.tryParse(quantityCtrl.text) ?? 0;
    if (quantity <= 0) {
      AppSnackbar.warning("الكمية يجب أن تكون أكبر من صفر");
      return;
    }
    final costPerUnit = double.tryParse(costPerUnitCtrl.text) ?? 0;
    if (costPerUnit <= 0) {
      AppSnackbar.warning("سعر الوحدة يجب أن تكون أكبر من صفر");
      return;
    }

    try {
      final purchase = PurchaseItem(
        productName: productNameCtrl.text,
        quantity: quantity,
        unit: selectedUnit.value,
        costPerUnit: costPerUnit,
        month: selectedMonth.value,
        year: selectedYear.value,
      );

      await _purchasesRepo.addPurchase(purchase);
      clearForm();
      showAddPurchaseForm.value = false;
      await loadReport();
      AppSnackbar.success("تمت إضافة المشتريات بنجاح");
    } catch (e) {
      AppSnackbar.error("فشل في إضافة المشتريات");
    }
  }

  Future<void> deletePurchase(int id, String productName) async {
    try {
      final deleted = await _purchasesRepo.deletePurchase(id);
      if (deleted) {
        purchases.removeWhere((p) => p.id == id);
        totalPurchaseCost.value = purchases.fold(0.0, (sum, p) => sum + p.totalCost);
        updateTableData();
        calculateNetProfit();
        AppSnackbar.warning("تم حذف $productName بنجاح");
      } else {
        AppSnackbar.error("فشل الحذف: العنصر غير موجود");
      }
    } catch (e) {
      print("❌ خطأ في الحذف: $e");
      AppSnackbar.error("حدث خطأ أثناء الحذف");
    }
  }

  void clearForm() {
    productNameCtrl.clear();
    quantityCtrl.clear();
    costPerUnitCtrl.clear();
    selectedCategory.value = 'بن';
  }

  @override
  void onClose() {
    productNameCtrl.dispose();
    quantityCtrl.dispose();
    costPerUnitCtrl.dispose();
    super.onClose();
  }
}