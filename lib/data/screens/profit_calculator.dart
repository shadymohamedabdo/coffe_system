import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/profit_controller.dart';

class ProfitCalculatorScreen extends GetView<ProfitController> {
  const ProfitCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfitController());
    final formatter = NumberFormat('#,###.##', 'ar_EG');

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F6), // لون خلفية هادئ
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildHeaderInfo(formatter),
                  const SizedBox(height: 24),
                  _buildModernForm(),
                  const SizedBox(height: 24),
                  _buildActionButton(),
                  const SizedBox(height: 24),
                  Obx(() => _buildResultSection(formatter)),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // AppBar بشكل عصري
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('حاسبة الأرباح', style: TextStyle(fontWeight: FontWeight.bold)),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal[900]!, Colors.teal[600]!],
              begin: Alignment.topRight,
            ),
          ),
        ),
      ),
    );
  }

  // كارت المبيعات العلوي
  Widget _buildHeaderInfo(NumberFormat formatter) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إجمالي الدخل', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                '${formatter.format(controller.totalSales.value)} ج.م',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ],
          ),
          CircleAvatar(
            backgroundColor: Colors.teal[50],
            radius: 25,
            child: const Icon(Icons.account_balance_wallet, color: Colors.teal),
          )
        ],
      ),
    ));
  }

  // فورم المصروفات بشكل مودرن
  Widget _buildModernForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.receipt_long, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text('المصروفات التشغيلية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _modernInput(controller.rentCtrl, 'الإيجار', Icons.storefront),
          _modernInput(controller.salariesCtrl, 'المرتبات', Icons.badge),
          Row(
            children: [
              Expanded(child: _modernInput(controller.electricityCtrl, 'كهرباء', Icons.bolt)),
              const SizedBox(width: 12),
              Expanded(child: _modernInput(controller.waterCtrl, 'مياه', Icons.opacity)),
            ],
          ),
          _modernInput(controller.otherCtrl, 'مصاريف نثرية', Icons.category),
        ],
      ),
    );
  }

  Widget _modernInput(TextEditingController ctrl, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        onChanged: (_) => controller.resetCalculation(),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
          filled: true,
          fillColor: Colors.grey[50],
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.grey[200]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      ),
    );
  }

  // زر الحساب التفاعلي
  Widget _buildActionButton() {
    return Obx(() => AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: controller.calculate,
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.isCalculated.value ? Colors.orange : Colors.teal[700],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          elevation: 5,
        ),
        child: const Text('تحليل الأرباح الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    ));
  }

  // منطقة النتائج "الكريتيف"
  Widget _buildResultSection(NumberFormat formatter) {
    if (!controller.isCalculated.value) return const SizedBox();

    final isProfit = controller.netProfit.value >= 0;

    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double val, child) {
        return Opacity(
          opacity: val,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - val)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isProfit ? Colors.green[600] : Colors.red[600],
                borderRadius: BorderRadius.circular(30),
                boxShadow: [BoxShadow(color: (isProfit ? Colors.green : Colors.red).withOpacity(0.3), blurRadius: 20)],
              ),
              child: Column(
                children: [
                  Icon(isProfit ? Icons.trending_up : Icons.trending_down, color: Colors.white, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    isProfit ? 'ما شاء الله! صافي ربحك' : 'للأسف! لديك خسارة بمقدار',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${formatter.format(controller.netProfit.value.abs())} ج.م',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(color: Colors.white24),
                  ),
                  _resultRow('إجمالي التكاليف', formatter.format(controller.totalExpenses.value)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _resultRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text('$value ج.م', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }
}