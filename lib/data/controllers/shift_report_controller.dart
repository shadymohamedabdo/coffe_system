import 'package:flutter/material.dart';
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

  // إحصائيات
  var totalSum = 0.0.obs;
  var ordersCount = 0.obs;
  var cancelledSum = 0.0.obs;

  // Pagination
  var currentPage = 1.obs;
  var hasMoreData = true.obs;
  var isLoadingMore = false.obs;
  final int pageSize = 20;

  // ScrollController يُدار داخل الـ Controller
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        loadMoreTransactions();
      }
    });
    loadAllShifts();
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> loadAllShifts() async {
    isLoading(true);
    try {
      final db = await dbHelper.database;
      final data = await db.query('shifts', orderBy: 'id DESC');
      shifts.assignAll(data);
      if (data.isNotEmpty) {
        selectedShiftId.value = data.first['id'] as int?;
        await loadReport(reset: true);
      }
    } finally {
      isLoading(false);
    }
  }

  Future<void> loadReport({bool reset = true}) async {
    if (selectedShiftId.value == null) return;

    if (reset) {
      currentPage.value = 1;
      hasMoreData.value = true;
      reportData.clear();
    }

    if (reset) {
      isLoading(true);
    } else {
      isLoadingMore(true);
    }

    try {
      final data = await _repo.getShiftReportPaginated(
        selectedShiftId.value!,
        limit: pageSize,
        offset: (currentPage.value - 1) * pageSize,
      );

      if (data.isEmpty) {
        hasMoreData.value = false;
      } else {
        if (reset) {
          reportData.assignAll(data);
        } else {
          reportData.addAll(data);
        }
        if (data.length < pageSize) {
          hasMoreData.value = false;
        }
      }
      _calculateStatistics();
    } finally {
      if (reset) {
        isLoading(false);
      } else {
        isLoadingMore(false);
      }
    }
  }

  Future<void> loadMoreTransactions() async {
    if (!hasMoreData.value || isLoadingMore.value) return;
    currentPage.value++;
    await loadReport(reset: false);
  }

  void selectShift(int shiftId) {
    selectedShiftId.value = shiftId;
    loadReport(reset: true);
  }

  void _calculateStatistics() {
    double activeSum = 0.0;
    double cancelled = 0.0;
    int count = 0;

    for (var item in reportData) {
      double amount = (item['total_amount'] as num).toDouble();
      if (item['status'] == 'active') {
        activeSum += amount;
        count++;
      } else {
        cancelled += amount;
      }
    }

    totalSum.value = activeSum;
    ordersCount.value = count;
    cancelledSum.value = cancelled;
  }

  Future<void> toggleStatus(int id, String currentStatus) async {
    String nextStatus = (currentStatus == 'active') ? 'cancelled' : 'active';
    await _repo.updateSaleStatus(id, nextStatus);
    await loadReport(reset: true);
  }
}