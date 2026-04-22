import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/reports_repository.dart';

class ProfitController extends GetxController {
  final repo = ReportsRepository();

  // حقول الإدخال
  final rentCtrl = TextEditingController();
  final salariesCtrl = TextEditingController();
  final electricityCtrl = TextEditingController();
  final waterCtrl = TextEditingController();
  final otherCtrl = TextEditingController();

  // متغيرات الحالة (Reactive)
  var totalSales = 0.0.obs;
  var netProfit = 0.0.obs;
  var totalExpenses = 0.0.obs;
  var isLoading = true.obs;
  var isCalculated = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadMonthlySales();
  }

  Future<void> loadMonthlySales() async {
    isLoading(true);
    try {
      final now = DateTime.now();
      // ✅ التصحيح: استخدام معاملات موضعية بدلاً من المسماة
      final data = await repo.getMonthlyReport(now.month, now.year);

      final sales = data.fold<double>(
        0.0,
            (sum, item) => sum + (item['total_amount'] as num).toDouble(),
      );

      totalSales.value = sales;
    } catch (e) {
      Get.snackbar("خطأ", "فشل تحميل المبيعات: $e", backgroundColor: Colors.red[100]);
    } finally {
      isLoading(false);
    }
  }

  void calculate() {
    double parse(TextEditingController controller) {
      String text = controller.text.replaceAll(',', '').trim();
      return double.tryParse(text) ?? 0.0;
    }

    totalExpenses.value = parse(rentCtrl) +
        parse(salariesCtrl) +
        parse(electricityCtrl) +
        parse(waterCtrl) +
        parse(otherCtrl);

    netProfit.value = totalSales.value - totalExpenses.value;
    isCalculated(true);
  }

  void resetCalculation() {
    isCalculated(false);
  }
}