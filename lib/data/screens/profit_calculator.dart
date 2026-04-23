import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/profit_controller.dart';

class ProfitCalculatorScreen extends GetView<ProfitController> {
  const ProfitCalculatorScreen({super.key});

  static final _formatter = NumberFormat('#,###.##', 'ar_EG');

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F6),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildProfitCard(),
                    const SizedBox(height: 20),
                    _buildGrossProfitCard(),
                    const SizedBox(height: 20),
                    _buildExpensesForm(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 40),
                  ]),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildSliverAppBar() => SliverAppBar(
    expandedHeight: 120,
    pinned: true,
    backgroundColor: Colors.teal[800],
    flexibleSpace: FlexibleSpaceBar(
      centerTitle: true,
      title: const Text('حاسبة صافي الربح', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      background: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Colors.teal.shade900, Colors.teal.shade600], begin: Alignment.topRight),
        ),
      ),
    ),
  );

  Widget _buildProfitCard() {
    return Obx(() {
      final isProfit = controller.netProfit.value >= 0;
      final color = isProfit ? Colors.green.shade700 : Colors.red.shade700;
      final icon = isProfit ? Icons.trending_up : Icons.trending_down;
      return TweenAnimationBuilder(
        key: ValueKey(controller.netProfit.value),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
        tween: Tween<double>(begin: 0, end: 1),
        builder: (_, double val, __) => Opacity(
          opacity: val,
          child: Transform.scale(
            scale: 0.95 + (0.05 * val),
            child: Card(
              color: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              elevation: 8,
              shadowColor: color.withOpacity(0.4),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(icon, color: Colors.white, size: 32),
                      const SizedBox(width: 12),
                      Text(isProfit ? 'صافي الربح الشهري' : 'صافي الخسارة الشهرية',
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 16),
                    Text('${_formatter.format(controller.netProfit.value.abs())} ج.م',
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                    const Divider(color: Colors.white54, height: 32),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('المبيعات: ${_formatter.format(controller.totalSales.value)} ج.م',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('المشتريات: ${_formatter.format(controller.totalPurchases.value)} ج.م',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ]),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('الربح الإجمالي: ${_formatter.format(controller.grossProfit.value)} ج.م',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      Text('المصروفات: ${_formatter.format(controller.totalExpenses.value)} ج.م',
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ]),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGrossProfitCard() => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('الربح الإجمالي (قبل خصم المصروفات)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      Text('${_formatter.format(controller.grossProfit.value)} ج.م',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal.shade700)),
      const SizedBox(height: 4),
      Text('المبيعات: ${_formatter.format(controller.totalSales.value)} ج.م  |  المشتريات: ${_formatter.format(controller.totalPurchases.value)} ج.م',
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
    ]),
  );

  Widget _buildExpensesForm() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Row(children: [Icon(Icons.receipt_long, color: Colors.orange), SizedBox(width: 8), Text('المصروفات التشغيلية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]),
      const SizedBox(height: 20),
      _buildInputField(controller.rentCtrl, 'الإيجار', Icons.storefront, controller.rentFocus, controller.salariesFocus),
      _buildInputField(controller.salariesCtrl, 'المرتبات', Icons.badge, controller.salariesFocus, controller.electricityFocus),
      Row(children: [
        Expanded(child: _buildInputField(controller.electricityCtrl, 'كهرباء', Icons.bolt, controller.electricityFocus, controller.waterFocus)),
        const SizedBox(width: 12),
        Expanded(child: _buildInputField(controller.waterCtrl, 'مياه', Icons.opacity, controller.waterFocus, controller.otherFocus)),
      ]),
      _buildInputField(controller.otherCtrl, 'مصاريف أخرى', Icons.category, controller.otherFocus, null, isLast: true),
    ]),
  );

  Widget _buildInputField(TextEditingController ctrl, String label, IconData icon, FocusNode focusNode, FocusNode? nextFocus, {bool isLast = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: ctrl,
        focusNode: focusNode,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        onChanged: (_) => controller.isCalculated.value = false,
        onEditingComplete: () {
          if (isLast) {
            focusNode.unfocus();
            controller.calculate();
          } else {
            nextFocus?.requestFocus();
          }
        },
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.teal.shade400),
          filled: true,
          fillColor: Colors.grey.shade50,
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.teal, width: 2)),
        ),
      ),
    );
  }

  Widget _buildActionButtons() => Row(children: [
    Expanded(
      flex: 4,
      child: ElevatedButton.icon(
        onPressed: controller.calculate,
        icon: const Icon(Icons.calculate),
        label: const Text('حساب صافي الربح', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal.shade700, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)), padding: const EdgeInsets.symmetric(vertical: 16)),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      flex: 1,
      child: Container(
        height: 56,
        decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(18)),
        child: IconButton(onPressed: controller.resetExpenses, icon: const Icon(Icons.refresh, color: Colors.orange), tooltip: 'مسح المصروفات'),
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      flex: 1,
      child: Obx(() => Container(
        height: 56,
        decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(18)),
        child: controller.isRefreshing.value
            ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue)))
            : IconButton(onPressed: controller.refreshData, icon: const Icon(Icons.sync, color: Colors.blue), tooltip: 'تحديث المبيعات والمشتريات'),
      )),
    ),
  ]);
}