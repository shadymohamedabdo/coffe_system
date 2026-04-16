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
      backgroundColor: const Color(0xFFF8F5F2), // لون كريمي هادي (لون القهوة بالحليب)
      appBar: AppBar(
        title: const Text('تقرير الوردية', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.sync), onPressed: () => controller.loadAllShifts()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.shifts.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Colors.brown));
        }

        return Column(
          children: [
            // --- 1. اختيار الوردية بشكل أفقي (Creative Slider) ---
            Container(
              height: 100,
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

            // --- 2. كروت الإحصائيات (Summary) ---
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

            // --- 3. قائمة المبيعات بتصميم Receipt ---
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

  // ويدجت الشريحة الخاصة بالوردية
  Widget _buildShiftChip(Map s, bool isSelected, ShiftReportController controller) {
    String type = s['type'] ?? "";
    DateTime? start = s['start_time'] != null ? DateTime.parse(s['start_time']) : null;

    return GestureDetector(
      onTap: () {
        controller.selectedShiftId.value = s['id'];
        controller.loadReport();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.brown[700] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [if (isSelected) BoxShadow(color: Colors.brown.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
          border: Border.all(color: isSelected ? Colors.brown[700]! : Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(type, style: TextStyle(color: isSelected ? Colors.white : Colors.brown, fontWeight: FontWeight.bold)),
            if (start != null)
              Text(DateFormat('dd/MM').format(start), style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  // كروت الإحصائيات
  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
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

  Widget _buildTransactionList(ShiftReportController controller, bool isAdmin) {
    if (controller.reportData.isEmpty) {
      return const Center(child: Text('لا توجد مبيعات حالياً'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.reportData.length,
      itemBuilder: (context, index) {
        final row = controller.reportData[index];
        bool isCancelled = row['status'] == 'cancelled';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isCancelled ? Colors.red.shade100 : Colors.transparent),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: isCancelled ? Colors.red[50] : Colors.brown[50], shape: BoxShape.circle),
              child: Icon(isCancelled ? Icons.close : Icons.coffee, color: isCancelled ? Colors.red : Colors.brown),
            ),
            title: Text(row['product_name'] ?? "منتج", style: TextStyle(fontWeight: FontWeight.bold, decoration: isCancelled ? TextDecoration.lineThrough : null)),
            subtitle: Text("${row['sale_time'] ?? ''} • ${row['employee_name'] ?? ''}", style: const TextStyle(fontSize: 11)),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${row['total_amount']} ج", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (isAdmin)
                  InkWell(
                    onTap: () => controller.toggleStatus(row['id'], row['status']),
                    child: Text(isCancelled ? "استعادة" : "إلغاء", style: TextStyle(color: isCancelled ? Colors.blue : Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}