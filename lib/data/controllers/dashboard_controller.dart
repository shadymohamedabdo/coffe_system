import 'package:get/get.dart';
import '../models/dashboard_model.dart';
import '../repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final _repo = DashboardRepository();

  var dailySales = <DailySale>[].obs;
  var topProducts = <ProductSale>[].obs;
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  // متغيرات الفلتر
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;

  // Cache للبيانات المحسوبة
  var maxDailySales = 0.0.obs;

  double get totalSales => dailySales.fold(0, (sum, e) => sum + e.total);

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  Future<void> loadAllData() async {
    try {
      isLoading(true);
      hasError(false);
      errorMessage('');

      final rawSales = await _repo.getDailySales(selectedMonth.value, selectedYear.value);
      final products = await _repo.getTopProducts(selectedMonth.value, selectedYear.value);

      // حساب عدد أيام الشهر المختار
      int daysInMonth = DateTime(selectedYear.value, selectedMonth.value + 1, 0).day;
      List<DailySale> fullMonth = [];

      for (int i = 1; i <= daysInMonth; i++) {
        final found = rawSales.firstWhere(
              (s) => s.day == i,
          orElse: () => DailySale(day: i, total: 0.0),
        );
        fullMonth.add(DailySale(day: i, total: found.total));
      }

      dailySales.assignAll(fullMonth);
      topProducts.assignAll(products);

      // حساب القيمة القصوى للرسم البياني
      if (fullMonth.isNotEmpty) {
        maxDailySales.value = fullMonth.map((e) => e.total).reduce((a, b) => a > b ? a : b) * 1.2;
      }
    } catch (e) {
      hasError(true);
      errorMessage('فشل في تحميل البيانات: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  // تغيير الشهر/السنة
  void changeMonth(int month) {
    selectedMonth.value = month;
    loadAllData();
  }

  void changeYear(int year) {
    selectedYear.value = year;
    loadAllData();
  }
}