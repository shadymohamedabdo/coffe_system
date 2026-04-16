import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: controller.loadAllData),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.brown));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTotalSalesCard(controller.totalSales),
              const SizedBox(height: 20),
              if (controller.dailySales.isNotEmpty) _buildChartCard(controller),
              const SizedBox(height: 20),
              if (controller.topProducts.isNotEmpty) _buildTopProductsCard(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTotalSalesCard(double total) {
    return Card(
      color: Colors.green[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('إجمالي مبيعات الشهر الحالي', style: TextStyle(color: Colors.white70)),
            Text(
              '${total.toStringAsFixed(2)} ج.م',
              style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ... (ويدجت الرسم البياني _buildChartCard تظل كما هي)

  Widget _buildTopProductsCard(DashboardController controller) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أعلى 5 منتجات مبيعًا', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...controller.topProducts.map((p) {

              // تحديد الأيقونة واللون ديناميكياً بناءً على الوحدة أو الاسم
              IconData itemIcon;
              Color iconColor;

              if (p.unitType == 'كيلو' || p.unitType == 'kg') {
                itemIcon = Icons.grain;
                iconColor = Colors.brown;
              } else if (p.unitType == 'قطعة' || p.unitType == 'piece') {
                itemIcon = Icons.fastfood;
                iconColor = Colors.orange;
              } else {
                itemIcon = Icons.local_cafe;
                iconColor = Colors.blue;
              }

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: iconColor.withOpacity(0.1),
                  child: Icon(itemIcon, color: iconColor, size: 20),
                ),
                title: Text(p.productName),
                trailing: Text(
                  '${p.totalQuantity.toStringAsFixed(1)} ${p.unitType}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // إضافة ويدجت الشارت المحسنة
  Widget _buildChartCard(DashboardController controller) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              maxY: controller.dailySales.map((e) => e.total).reduce((a, b) => a > b ? a : b) * 1.2,
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 10)),
                  ),
                ),
              ),
              barGroups: controller.dailySales.map((e) {
                return BarChartGroupData(
                  x: int.parse(e.day),
                  barRods: [BarChartRodData(toY: e.total, color: Colors.brown, width: 12)],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}