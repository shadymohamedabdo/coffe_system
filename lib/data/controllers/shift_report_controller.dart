import 'package:get/get.dart';
import '../repositories/reports_repository.dart';
import '../database_helper.dart';

class ShiftReportController extends GetxController {
  final _repo = ReportsRepository();
  final dbHelper = DatabaseHelper.instance;

  var reportData = <Map<String, dynamic>>[].obs;
  var shifts = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var selectedShiftId = RxnInt();

  @override
  void onInit() {
    super.onInit();
    loadAllShifts();
  }

  Future<void> loadAllShifts() async {
    isLoading(true);
    final db = await dbHelper.database;
    final data = await db.query('shifts', orderBy: 'id DESC');
    shifts.assignAll(data);
    if (data.isNotEmpty) {
      selectedShiftId.value = data.first['id'] as int?;
      await loadReport();
    }
    isLoading(false);
  }

  Future<void> loadReport() async {
    if (selectedShiftId.value == null) return;
    isLoading(true);
    final data = await _repo.getShiftReport(selectedShiftId.value!);
    reportData.assignAll(data);
    isLoading(false);
  }

  // إحصائيات ذكية للشاشة
  double get totalSum => reportData.where((e) => e['status'] == 'active').fold(0.0, (sum, item) => sum + (item['total_amount'] as num).toDouble());
  int get ordersCount => reportData.where((e) => e['status'] == 'active').length;
  double get cancelledSum => reportData.where((e) => e['status'] == 'cancelled').fold(0.0, (sum, item) => sum + (item['total_amount'] as num).toDouble());

  Future<void> toggleStatus(int id, String currentStatus) async {
    String nextStatus = (currentStatus == 'active') ? 'cancelled' : 'active';
    await _repo.updateSaleStatus(id, nextStatus);
    await loadReport();
  }
}