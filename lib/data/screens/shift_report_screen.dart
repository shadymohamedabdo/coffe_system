import 'package:flutter/material.dart';
import '../repositories/reports_repository.dart';

class ShiftReportScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const ShiftReportScreen({super.key, required this.currentUser});

  @override
  State<ShiftReportScreen> createState() => _ShiftReportScreenState();
}

class _ShiftReportScreenState extends State<ShiftReportScreen> {
  final _repo = ReportsRepository();
  List<Map<String, dynamic>> report = [];
  int selectedShiftId = 1; // كمثال، يفضل جلبه من قائمة الشفتات

  Future<void> loadReport() async {
    final data = await _repo.getShiftReport(selectedShiftId);
    setState(() => report = data);
  }

  Future<void> toggleStatus(int id, String currentStatus) async {
    String nextStatus = (currentStatus == 'active') ? 'cancelled' : 'active';
    await _repo.updateSaleStatus(id, nextStatus);
    loadReport(); // تحديث القائمة بعد التعديل
  }

  double get totalSum {
    return report.where((e) => e['status'] == 'active')
        .fold(0, (sum, item) => sum + (item['total_amount'] as num));
  }

  @override
  Widget build(BuildContext context) {
    bool isAdmin = widget.currentUser['role'] == 'admin';

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الشفت'), backgroundColor: Colors.brown),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: ElevatedButton(onPressed: loadReport, child: const Text('تحديث بيانات الشفت')),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: report.length,
              itemBuilder: (context, index) {
                final row = report[index];
                bool isCancelled = row['status'] == 'cancelled';

                return Card(
                  color: isCancelled ? Colors.red[50] : null,
                  child: ListTile(
                    title: Text(row['product_name'], style: TextStyle(decoration: isCancelled ? TextDecoration.lineThrough : null)),
                    subtitle: Text('بواسطة: ${row['employee_name']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${row['total_amount']} ج'),
                        const SizedBox(width: 10),
                        if (isAdmin)
                          IconButton(
                            icon: Icon(isCancelled ? Icons.undo : Icons.cancel, color: isCancelled ? Colors.green : Colors.red),
                            onPressed: () => toggleStatus(row['id'], row['status']),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            color: Colors.blueGrey[900],
            child: Text('صافي مبيعات الشفت: ${totalSum.toStringAsFixed(2)} ج.م',
                style: const TextStyle(color: Colors.white, fontSize: 18), textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}