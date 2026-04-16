import 'package:get/get.dart';
import '../models/dashboard_model.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repo = DashboardRepository();

  // متغيرات مراقبة (Observable)
  var dailySales = <DailySale>[].obs;
  var topProducts = <ProductSale>[].obs;
  var isLoading = true.obs;
  var errorMessage = "".obs;

  // خاصية لحساب إجمالي المبيعات تلقائياً
  double get totalSales => dailySales.fold(0, (sum, e) => sum + e.total);

  @override
  void onInit() {
    super.onInit();
    loadAllData(); // جلب البيانات بمجرد تشغيل الـ Controller
  }

  Future<void> loadAllData() async {
    try {
      isLoading(true);
      errorMessage(""); // تصغير الرسالة لو كانت موجودة

      final now = DateTime.now();
      final sales = await _repo.getDailySales(now.month, now.year);
      final products = await _repo.getTopProducts(now.month, now.year);

      dailySales.assignAll(sales);
      topProducts.assignAll(products);
    } catch (e) {
      errorMessage("فشل في تحميل البيانات: $e");
    } finally {
      isLoading(false);
    }
  }
}