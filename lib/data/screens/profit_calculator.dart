import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../repositories/reports_repository.dart';

class ProfitCalculatorScreen extends StatefulWidget {
  const ProfitCalculatorScreen({super.key});

  @override
  State<ProfitCalculatorScreen> createState() => _ProfitCalculatorScreenState();
}

class _ProfitCalculatorScreenState extends State<ProfitCalculatorScreen> {
  final repo = ReportsRepository();

  // تحكم الحقول
  final rentCtrl = TextEditingController();
  final salariesCtrl = TextEditingController();
  final electricityCtrl = TextEditingController();
  final waterCtrl = TextEditingController();
  final otherCtrl = TextEditingController();

  double totalSales = 0.0;
  double netProfit = 0.0;
  double totalExpenses = 0.0;
  bool isLoading = true;
  bool calculated = false;

  final _formatter = NumberFormat('#,###.##', 'ar_EG');

  @override
  void initState() {
    super.initState();
    loadMonthlySales();
  }

  Future<void> loadMonthlySales() async {
    setState(() => isLoading = true);
    try {
      final now = DateTime.now();
      final data = await repo.getMonthlyReport(month: now.month, year: now.year);

      // تعديل هنا لضمان عدم حدوث Type Error
      final sales = data.fold<double>(
        0.0,
            (sum, item) => sum + (item['total_amount'] as num).toDouble(),
      );

      setState(() {
        totalSales = sales;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showError('فشل تحميل المبيعات: $e');
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  void calculate() {
    // ميثود مساعدة لتحويل النص لرقم بأمان
    double parse(TextEditingController controller) {
      String text = controller.text.replaceAll(',', '').trim();
      return double.tryParse(text) ?? 0.0;
    }

    final rent = parse(rentCtrl);
    final salaries = parse(salariesCtrl);
    final electricity = parse(electricityCtrl);
    final water = parse(waterCtrl);
    final other = parse(otherCtrl);

    setState(() {
      totalExpenses = rent + salaries + electricity + water + other;
      netProfit = totalSales - totalExpenses;
      calculated = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('حاسبة صافي الربح'),
        backgroundColor: Colors.teal[800],
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              children: [
                _buildSalesCard(),
                const SizedBox(height: 20),
                _buildExpensesForm(),
                if (calculated) _buildResultCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalesCard() {
    return Card(
      elevation: 4,
      color: Colors.teal[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
          children: [
            const Text('إجمالي مبيعات الشهر الحالي', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              '${_formatter.format(totalSales)} ج.م',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أدخل المصروفات الشهرية:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            _inputField('إيجار المحل', rentCtrl, Icons.home_work),
            _inputField('مرتبات الموظفين', salariesCtrl, Icons.people),
            _inputField('فاتورة الكهرباء', electricityCtrl, Icons.electric_bolt),
            _inputField('فاتورة المياه', waterCtrl, Icons.water_drop),
            _inputField('مصروفات أخرى', otherCtrl, Icons.more_horiz),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: calculate,
                icon: const Icon(Icons.calculate),
                label: const Text('احسب صافي الربح', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => setState(() => calculated = false),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.teal),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }

  Widget _buildResultCard() {
    final bool isProfit = netProfit >= 0;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Card(
        color: isProfit ? Colors.green[50] : Colors.red[50],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(color: isProfit ? Colors.green : Colors.red, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Text(
                isProfit ? 'صافي الأرباح' : 'صافي الخسارة',
                style: TextStyle(fontSize: 18, color: isProfit ? Colors.green[800] : Colors.red[800]),
              ),
              const SizedBox(height: 5),
              Text(
                '${_formatter.format(netProfit.abs())} ج.م',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isProfit ? Colors.green[900] : Colors.red[900]),
              ),
              const Divider(),
              Text('إجمالي المصروفات: ${_formatter.format(totalExpenses)} ج.م', style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }
}