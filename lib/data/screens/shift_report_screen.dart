import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/shift_report_controller.dart';

class ShiftReportScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  const ShiftReportScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ShiftReportController());
    bool isAdmin = currentUser['role'] == 'admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F2),
      appBar: AppBar(
        title: const Text('تقرير الوردية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'تحديث البيانات',
            onPressed: () => controller.loadAllShifts(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.shifts.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.brown));
        }

        return Column(
          children: [
            // ===== الشيفتات =====
            Container(
              height: 110,
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: controller.shifts.length,
                itemBuilder: (context, index) {
                  final s = controller.shifts[index];
                  final isSelected = controller.selectedShiftId.value == s['id'];
                  return _buildShiftChip(s, isSelected, controller);
                },
              ),
            ),

            // ===== الإحصائيات =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildStatCard("إجمالي البيع", "${controller.totalSum.toStringAsFixed(1)} ج", Colors.green, Icons.monetization_on),
                  const SizedBox(width: 10),
                  _buildStatCard("عدد الطلبات", "${controller.ordersCount}", Colors.blue, Icons.shopping_basket),
                ],
              ),
            ),

            const SizedBox(height: 15),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.list_alt, size: 18, color: Colors.brown),
                  SizedBox(width: 8),
                  Text("تفاصيل العمليات", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            ),

            // ===== قائمة العمليات =====
            Expanded(
              child: controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : _buildTransactionList(controller, isAdmin),
            ),
          ],
        );
      }),
    );
  }

  // ===== شكل الشيفت =====
  Widget _buildShiftChip(Map s, bool isSelected, ShiftReportController controller) {
    print("SHIFT DATA: $s"); // 👈 Debug

    String typeFromDb = s['type']?.toString() ?? "";

    DateTime? dt;

    try {
      if (s['start_time'] != null && s['start_time'].toString().isNotEmpty) {
        dt = DateTime.parse(s['start_time']).toLocal();
      } else if (s['date'] != null) {
        dt = DateTime.parse(s['date']);
      }
    } catch (e) {
      print("DATE ERROR: $e");
    }

    String displayDate = dt != null
        ? DateFormat('yyyy/MM/dd').format(dt)
        : "—";

    String displayTime = dt != null
        ? DateFormat('hh:mm a').format(dt)
        : "";

    return GestureDetector(
      onTap: () {
        controller.selectedShiftId.value = s['id'];
        controller.loadReport();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        width: 140,
        decoration: BoxDecoration(
          color: isSelected ? Colors.brown : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              typeFromDb == "morning" ? "☀️ صباحي" : "🌙 مسائي",
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              displayDate,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 12,
              ),
            ),

            if (displayTime.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                displayTime,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black54,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // ===== قائمة العمليات =====
  Widget _buildTransactionList(ShiftReportController controller, bool isAdmin) {
    if (controller.reportData.isEmpty) return const Center(child: Text('لا توجد مبيعات'));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.reportData.length,
      itemBuilder: (context, index) {
        final row = controller.reportData[index];
        bool isCancelled = row['status'] == 'cancelled';

        num quantity = row['quantity'] ?? 0;
        String unit = row['unit'] ?? '';
        String qtyStr = (quantity % 1 == 0) ? quantity.toInt().toString() : quantity.toString();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: isCancelled ? Colors.red[50] : Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(row['product_name'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text("👤 ${row['employee_name'] ?? ''}", style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      "الكمية: $qtyStr $unit",
                      style: TextStyle(fontSize: 11, color: Colors.orange[900], fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${row['total_amount']} ج", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                if (isAdmin)
                  GestureDetector(
                    onTap: () => controller.toggleStatus(row['id'], row['status']),
                    child: Text(
                      isCancelled ? "استعادة" : "إلغاء",
                      style: TextStyle(
                        color: isCancelled ? Colors.blue : Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
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