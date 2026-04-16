import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/profit_controller.dart';

class ProfitCalculatorScreen extends StatelessWidget {
  const ProfitCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ربط الكنترولر
    final controller = Get.put(ProfitController());
    final formatter = NumberFormat('#,###.##', 'ar_EG');

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
                // كارت المبيعات
                Obx(() => _buildSalesCard(controller, formatter)),
                const SizedBox(height: 20),

                // فورم المصروفات
                _buildExpensesForm(controller),

                // نتيجة الحساب
                Obx(() => controller.isCalculated.value
                    ? _buildResultCard(controller, formatter)
                    : const SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSalesCard(ProfitController controller, NumberFormat formatter) {
    return Card(
      elevation: 4,
      color: Colors.teal[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: controller.isLoading.value
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Column(
          children: [
            const Text('إجمالي مبيعات الشهر الحالي', style: TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              '${formatter.format(controller.totalSales.value)} ج.م',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesForm(ProfitController controller) {
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
            _inputField('إيجار المحل', controller.rentCtrl, Icons.home_work, controller),
            _inputField('مرتبات الموظفين', controller.salariesCtrl, Icons.people, controller),
            _inputField('فاتورة الكهرباء', controller.electricityCtrl, Icons.electric_bolt, controller),
            _inputField('فاتورة المياه', controller.waterCtrl, Icons.water_drop, controller),
            _inputField('مصروفات أخرى', controller.otherCtrl, Icons.more_horiz, controller),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: controller.calculate,
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

  Widget _inputField(String label, TextEditingController ctrl, IconData icon, ProfitController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => controller.resetCalculation(),
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

  Widget _buildResultCard(ProfitController controller, NumberFormat formatter) {
    final bool isProfit = controller.netProfit.value >= 0;
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
                '${formatter.format(controller.netProfit.value.abs())} ج.م',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: isProfit ? Colors.green[900] : Colors.red[900]),
              ),
              const Divider(),
              Text(
                'إجمالي المصروفات: ${formatter.format(controller.totalExpenses.value)} ج.م',
                style: const TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}