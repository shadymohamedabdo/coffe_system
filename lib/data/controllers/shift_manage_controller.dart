import 'package:get/get.dart';
import '../models/shift_model.dart';
import '../repositories/shifts_repository.dart';
import '../constants.dart';

class ShiftsController extends GetxController {
  final repo = ShiftsRepository();

  var openShift = Rxn<ShiftModel>();
  var allShifts = <ShiftModel>[].obs;

  // جعلناها false افتراضياً لإخفاء دائرة التحميل الرئيسية
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var isProcessing = false.obs;

  var hasMoreData = true.obs;

  int _currentOffset = 0;
  final int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    // التحميل الأول يتم في الخلفية فوراً
    loadInitialData(showLoader: true);
  }

  // ===================== أول تحميل =====================
  // أضفنا متغير showLoader للتحكم في ظهور الدائرة من عدمه
  Future<void> loadInitialData({bool showLoader = false}) async {
    try {
      if (showLoader) isLoading.value = true;

      _currentOffset = 0;
      hasMoreData.value = true;

      // سحب البيانات من المستودع
      final currentMap = await repo.getOpenShift();
      final historyMaps = await repo.getAllShifts(limit: _limit, offset: _currentOffset);

      // تحديث القيم - الـ Obx في الواجهة سيحدث البيانات تلقائياً دون الحاجة لدائرة تحميل
      openShift.value = currentMap != null ? ShiftModel.fromMap(currentMap) : null;

      allShifts.assignAll(
        historyMaps.map((m) => ShiftModel.fromMap(m)).toList(),
      );

      if (historyMaps.length < _limit) {
        hasMoreData.value = false;
      }
    } catch (e) {
      AppSnackbar.error("فشل تحميل البيانات");
    } finally {
      isLoading.value = false;
    }
  }

  // ===================== فتح شفت =====================
  Future<void> startShift(String type, String userName) async {
    try {
      if (isProcessing.value) return;
      isProcessing.value = true;

      await repo.openShift(type, userName);

      // هنا استدعاء البيانات في الخلفية بدون showLoader
      await loadInitialData(showLoader: false);

      AppSnackbar.success("تم فتح الشفت بنجاح");
    } catch (e) {
      AppSnackbar.error("فشل فتح الشفت");
    } finally {
      isProcessing.value = false;
    }
  }

  // ===================== قفل شفت =====================
  Future<void> endShift(int id) async {
    try {
      if (isProcessing.value) return;
      isProcessing.value = true;

      await repo.closeShift(id);

      // تحديث البيانات في الخلفية فوراً بعد إغلاق الشفت
      await loadInitialData(showLoader: false);

      AppSnackbar.warning("تم إغلاق الشفت");
    } catch (e) {
      AppSnackbar.error("فشل إغلاق الشفت");
    } finally {
      isProcessing.value = false;
    }
  }

// دالة loadMoreShifts تظل كما هي لأنها تستخدم isLoadingMore المنفصلة
}