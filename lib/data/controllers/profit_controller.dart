import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/reports_repository.dart';
import '../repositories/purchases_repository.dart';

class ProfitController extends GetxController {
  final ReportsRepository _repo = ReportsRepository();
  final PurchasesRepository _purchasesRepo = PurchasesRepository();

  // TextEditingControllers
  final rentCtrl = TextEditingController();
  final salariesCtrl = TextEditingController();
  final electricityCtrl = TextEditingController();
  final waterCtrl = TextEditingController();
  final otherCtrl = TextEditingController();

  // FocusNodes
  final rentFocus = FocusNode();
  final salariesFocus = FocusNode();
  final electricityFocus = FocusNode();
  final waterFocus = FocusNode();
  final otherFocus = FocusNode();

  // Reactive variables
  final totalSales = 0.0.obs;
  final totalPurchases = 0.0.obs;
  final grossProfit = 0.0.obs;
  final totalExpenses = 0.0.obs;
  final netProfit = 0.0.obs;
  final isLoading = true.obs;
  final isRefreshing = false.obs;
  final isCalculated = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMonthlyData();
  }

  Future<void> loadMonthlyData() async {
    isLoading(true);
    try {
      final now = DateTime.now();
      final salesData = await _repo.getMonthlyReport(now.month, now.year);
      totalSales.value = salesData.fold(0.0, (s, i) => s + (i['total_amount'] as num));

      final purchases = await _purchasesRepo.getPurchasesForMonth(now.month, now.year);
      totalPurchases.value = purchases.fold(0.0, (s, p) => s + p.totalCost);

      grossProfit.value = totalSales.value - totalPurchases.value;
      _recalculate();
    } catch (e) {
      _showError('فشل تحميل البيانات: $e');
    } finally {
      isLoading(false);
    }
  }

  Future<void> refreshData() async {
    isRefreshing(true);
    await loadMonthlyData();
    isRefreshing(false);
  }

  void _updateExpenses() {
    double parse(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0.0;
    totalExpenses.value = parse(rentCtrl) + parse(salariesCtrl) + parse(electricityCtrl) + parse(waterCtrl) + parse(otherCtrl);
  }

  void _recalculate() {
    _updateExpenses();
    netProfit.value = grossProfit.value - totalExpenses.value;
  }

  void calculate() {
    _recalculate();
    isCalculated(true);
    Get.focusScope?.unfocus();
  }

  void resetExpenses() {
    rentCtrl.clear();
    salariesCtrl.clear();
    electricityCtrl.clear();
    waterCtrl.clear();
    otherCtrl.clear();
    _recalculate();
    isCalculated(false);
  }

  void _showError(String msg) {
    Get.snackbar('خطأ', msg, backgroundColor: Colors.red.shade100, colorText: Colors.red.shade900);
  }

  @override
  void onClose() {
    // Dispose all controllers and focus nodes
    [rentCtrl, salariesCtrl, electricityCtrl, waterCtrl, otherCtrl].forEach((c) => c.dispose());
    [rentFocus, salariesFocus, electricityFocus, waterFocus, otherFocus].forEach((f) => f.dispose());
    super.onClose();
  }
}