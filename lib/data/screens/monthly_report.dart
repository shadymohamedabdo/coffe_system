import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/monthly_report_controller.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // حقن الـ Controller
    final controller = Get.put(MonthlyReportController());

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('التقرير الشهري'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadReport,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // عرض التاريخ الحالي
            Text(
              "تقرير شهر ${DateTime.now().month} / ${DateTime.now().year}",
              style: TextStyle(color: Colors.brown[800], fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 20),

            // مراقبة الحالة (Loading, Error, Success)
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildLoading();
                }
                if (controller.errorMessage.isNotEmpty) {
                  return _buildError(controller);
                }
                if (controller.reportData.isEmpty) {
                  return const Center(child: Text('لا توجد مبيعات مسجلة لهذا الشهر'));
                }
                return _buildReportTable(controller);
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ودجيت التحميل
  Widget _buildLoading() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.brown),
          SizedBox(height: 20),
          Text('جاري استخراج التقرير...'),
        ],
      ),
    );
  }

  // ودجيت الخطأ
  Widget _buildError(MonthlyReportController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
          ElevatedButton(onPressed: controller.loadReport, child: const Text("إعادة المحاولة")),
        ],
      ),
    );
  }

  // ودجيت الجدول والإجمالي
  Widget _buildReportTable(MonthlyReportController controller) {
    return Column(
      children: [
        Expanded(
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(Colors.brown[400]),
                  columns: const [
                    DataColumn(label: Text('المنتج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('الكمية', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('السعر', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    DataColumn(label: Text('الإجمالي', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  ],
                  rows: controller.reportData.map((row) {
                    return DataRow(cells: [
                      DataCell(Text(row['product_name'] ?? '-')),
                      DataCell(Text(row['total_quantity'].toString())),
                      DataCell(Text('${row['unit_price']} ج.م')),
                      DataCell(Text('${(row['total_amount'] as num).toStringAsFixed(2)} ج.م',
                          style: const TextStyle(fontWeight: FontWeight.bold))),
                    ]);
                  }).toList(),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),

        // كارت الإجمالي النهائي
        Card(
          color: Colors.green[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payments, color: Colors.white),
                const SizedBox(width: 15),
                Text(
                  'إجمالي المبيعات: ${controller.totalSum.value.toStringAsFixed(2)} ج.م',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}