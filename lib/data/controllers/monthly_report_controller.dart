import 'package:get/get.dart';
import '../repositories/reports_repository.dart';

class MonthlyReportController extends GetxController {
  final ReportsRepository _repo = ReportsRepository();

  // متغيرات مراقبة
  var isLoading = true.obs;
  var errorMessage = "".obs;
  var reportData = <Map<String, dynamic>>[].obs;
  var totalSum = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadReport();
  }

  Future<void> loadReport() async {
    try {
      isLoading(true);
      errorMessage(""); // تصغير رسالة الخطأ لو كانت موجودة

      final now = DateTime.now();
      final result = await _repo.getMonthlyReport(
        month: now.month,
        year: now.year,
      );

      reportData.assignAll(result);

      // حساب الإجمالي الكلي
      totalSum.value = reportData.fold(
        0.0,
            (sum, item) => sum + (item['total_amount'] as num).toDouble(),
      );
    } catch (e) {
      errorMessage("حدث خطأ أثناء تحميل البيانات: $e");
    } finally {
      isLoading(false);
    }
  }
}