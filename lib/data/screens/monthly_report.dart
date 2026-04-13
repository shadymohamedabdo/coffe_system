import 'package:flutter/material.dart';
import '../repositories/reports_repository.dart'; // تأكد من صحة المسار

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  // تعريف المستودع لجلب البيانات
  final ReportsRepository _repo = ReportsRepository();

  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> data = [];
  double totalSum = 0;

  @override
  void initState() {
    super.initState();
    loadReport();
  }

  /// ميثود جلب البيانات من الداتا بيز
  void loadReport() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final now = DateTime.now();

      // استدعاء البيانات الحقيقية من الـ Repository
      final result = await _repo.getMonthlyReport(
        month: now.month,
        year: now.year,
      );

      setState(() {
        data = result;
        // حساب الإجمالي الكلي من الحقل القادم من الداتا بيز
        totalSum = data.fold(
          0.0,
              (sum, item) => sum + (item['total_amount'] as num).toDouble(),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "حدث خطأ أثناء تحميل البيانات: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            tooltip: 'تحديث التقرير',
            onPressed: loadReport,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 10),

            // عرض الشهر والسنة الحاليين
            Text(
              "تقرير شهر ${DateTime.now().month} / ${DateTime.now().year}",
              style: TextStyle(color: Colors.brown[800], fontWeight: FontWeight.bold, fontSize: 16),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  /// ويدجت بناء محتوى الصفحة بناءً على الحالة
  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.brown),
            SizedBox(height: 20),
            Text('جاري استخراج التقرير من الداتا بيز...', style: TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16), textAlign: TextAlign.center),
            ElevatedButton(onPressed: loadReport, child: const Text("إعادة المحاولة")),
          ],
        ),
      );
    }

    if (data.isEmpty) {
      return const Center(
        child: Text('لا توجد مبيعات مسجلة لهذا الشهر حتى الآن', style: TextStyle(fontSize: 18, color: Colors.brown)),
      );
    }

    return Column(
      children: [
        Expanded(
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Colors.white,
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowHeight: 56,
                    dataRowHeight: 60,
                    headingRowColor: WidgetStateProperty.all(Colors.brown[400]),
                    columns: const [
                      DataColumn(label: Text('المنتج', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                      DataColumn(label: Text('الكمية', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                      DataColumn(label: Text('السعر', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                      DataColumn(label: Text('الإجمالي', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),
                    ],
                    rows: data.map((row) {
                      return DataRow(
                        cells: [
                          DataCell(Text(row['product_name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(row['total_quantity'].toString())),
                          DataCell(Text('${row['unit_price']} ج.م')),
                          DataCell(Text('${(row['total_amount'] as num).toStringAsFixed(2)} ج.م',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown))),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // كارت الإجمالي الكلي
        Card(
          elevation: 8,
          color: Colors.green[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.account_balance_wallet, size: 32, color: Colors.white),
                const SizedBox(width: 16),
                Flexible(
                  child: Text(
                    'إجمالي مبيعات الشهر: ${totalSum.toStringAsFixed(2)} جنيه',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}