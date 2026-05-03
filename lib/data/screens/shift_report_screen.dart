import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/shift_report_controller.dart';

class ShiftReportScreen extends GetView<ShiftReportController> {
  final Map<String, dynamic> currentUser;

  const ShiftReportScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    // بنحدد لو المستخدم Admin ولا لأ
    bool isAdmin = currentUser['role'] == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F7),

      appBar: AppBar(
        title: const Text(
          'تقرير الوردية',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,

        actions: [
          // زرار تحديث الداتا
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: () => controller.loadAllShifts(),
          ),
        ],
      ),

      body: Obx(() {
        // لو لسه بيحمّل ومفيش داتا
        if (controller.isLoading.value && controller.shifts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.brown),
          );
        }

        return Column(
          children: [
            // شريط اختيار الشفتات (صباحي / مسائي)
            _buildShiftsHeader(),

            // كروت الإحصائيات
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  _buildStatCard(
                    "إجمالي المبيعات",
                    "${controller.totalSum.value.toStringAsFixed(2)} ج",
                    Colors.green,
                    Icons.payments_outlined,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    "الطلبات الناجحة",
                    "${controller.ordersCount.value}",
                    Colors.blue,
                    Icons.receipt_long_outlined,
                  ),
                ],
              ),
            ),

            // عنوان سجل العمليات
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Icon(Icons.list_alt_rounded, size: 20, color: Colors.brown),
                  SizedBox(width: 8),
                  Text(
                    "سجل عمليات الوردية",
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // القائمة الرئيسية للعمليات
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => controller.loadReport(reset: true),

                child: controller.reportData.isEmpty &&
                    !controller.isLoadingMore.value
                    ? const Center(
                  child: Text("لا توجد عمليات لهذه الوردية"),
                )
                    : _buildTransactionList(isAdmin),
              ),
            ),
          ],
        );
      }),
    );
  }

  // ================= SHIFTS HEADER =================

  Widget _buildShiftsHeader() {
    // شريط أفقي للشفتات
    return Container(
      height: 100,
      margin: const EdgeInsets.symmetric(vertical: 8),

      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.shifts.length,

        itemBuilder: (context, index) {
          final s = controller.shifts[index];

          // هل الشفت ده هو المختار
          final isSelected = controller.selectedShiftId.value == s['id'];

          return _buildShiftChip(s, isSelected);
        },
      ),
    );
  }

  // كارت الشفت (صباحي / مسائي)
  Widget _buildShiftChip(Map s, bool isSelected) {
    // تحويل التاريخ لصيغة محلية
    DateTime? dt = s['start_time'] != null
        ? DateTime.tryParse(s['start_time'].toString())?.toLocal()
        : null;

    String displayDate =
    dt != null ? DateFormat('MM/dd').format(dt) : "—";

    bool isMorning = s['type'] == "morning";

    return GestureDetector(
      onTap: () => controller.selectShift(s['id']),

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12, top: 4, bottom: 4),
        padding: const EdgeInsets.all(12),
        width: 120,

        decoration: BoxDecoration(
          color: isSelected ? Colors.brown[700] : Colors.white,
          borderRadius: BorderRadius.circular(20),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],

          border: Border.all(
            color: isSelected ? Colors.brown : Colors.grey.shade200,
          ),
        ),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // نوع الشفت
            Text(
              isMorning ? "☀️ صباحي" : "🌙 مسائي",
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.brown[900],
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 4),

            // التاريخ
            Text(
              displayDate,
              style: TextStyle(
                color: isSelected ? Colors.white70 : Colors.black54,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= STAT CARD =================

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),

          border: Border.all(color: color.withValues(alpha: 0.1)),

          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: color.withValues(alpha: 0.1),
              child: Icon(icon, color: color, size: 16),
            ),

            const SizedBox(height: 12),

            // العنوان
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 2),

            // القيمة
            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= TRANSACTIONS LIST =================

  Widget _buildTransactionList(bool isAdmin) {
    return ListView.builder(
      controller: controller.scrollController,

      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),

      itemCount: controller.reportData.length +
          (controller.hasMoreData.value ? 1 : 0),

      itemBuilder: (context, index) {
        // Loader في آخر الليست
        if (index == controller.reportData.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final row = controller.reportData[index];

        // هل العملية ملغية ولا لأ
        bool isCancelled = row['status'] == 'cancelled';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),

          decoration: BoxDecoration(
            color: isCancelled
                ? Colors.red.withValues(alpha: 0.03)
                : Colors.white,

            borderRadius: BorderRadius.circular(16),

            border: Border.all(
              color: isCancelled
                  ? Colors.red.withValues(alpha: 0.1)
                  : Colors.grey.shade100,
            ),
          ),

          child: ListTile(
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),

            // اسم المنتج
            title: Text(
              row['product_name'] ?? "منتج غير معروف",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                decoration:
                isCancelled ? TextDecoration.lineThrough : null,
              ),
            ),

            // التفاصيل
            subtitle: Row(
              children: [
                Text(
                  "👤 ${row['employee_name'] ?? ''}",
                  style:
                  const TextStyle(fontSize: 11, color: Colors.grey),
                ),

                const SizedBox(width: 8),

                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),

                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    borderRadius: BorderRadius.circular(6),
                  ),

                  child: Text(
                    "x${row['quantity']} ${row['unit'] ?? ''}",
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.brown[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // السعر + زرار الأدمن
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${row['total_amount']} ج",
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: isCancelled ? Colors.grey : Colors.black,
                    fontSize: 15,
                  ),
                ),

                // لو Admin يقدر يلغي أو يرجع العملية
                if (isAdmin)
                  InkWell(
                    onTap: () => controller.toggleStatus(
                      row['id'],
                      row['status'],
                    ),

                    child: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        isCancelled ? "إستعادة" : "إلغاء العملية",
                        style: TextStyle(
                          color: isCancelled
                              ? Colors.blue
                              : Colors.red[700],
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}