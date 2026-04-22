import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('لوحة الإحصائيات', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [_buildFilterHeader()],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.brown));
        }

        if (controller.hasError.value) {
          return _buildErrorWidget();
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadAllData(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSummaryCard(),
                const SizedBox(height: 20),
                _buildChartSection(),
                const SizedBox(height: 20),
                _buildTopProductsSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  // فلتر الشهر والسنة في الـ AppBar
  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: controller.selectedMonth.value,
              dropdownColor: Colors.brown[700],
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: List.generate(12, (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(_getMonthName(i + 1)),
              )),
              onChanged: (val) {
                if (val != null) controller.changeMonth(val);
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: controller.selectedYear.value,
              dropdownColor: Colors.brown[700],
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: [2024, 2025, 2026, 2027].map((y) => DropdownMenuItem(
                value: y,
                child: Text('$y'),
              )).toList(),
              onChanged: (val) {
                if (val != null) controller.changeYear(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return months[month - 1];
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => controller.loadAllData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[700],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: controller.totalSales),
      duration: const Duration(milliseconds: 800),
      builder: (context, double value, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.brown[700]!, Colors.brown[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              const Text(
                'إجمالي الدخل للشهر',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 12),
              Text(
                '${value.toStringAsFixed(2)} ج.م',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_getMonthName(controller.selectedMonth.value)} ${controller.selectedYear.value}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildChartSection() {
    if (controller.dailySales.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 أداء المبيعات اليومي',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(
                maxY: controller.maxDailySales.value,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() % 2 == 0 || value.toInt() == 1) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                ),
                barGroups: controller.dailySales.map((e) => BarChartGroupData(
                  x: e.day,
                  barRods: [
                    BarChartRodData(
                      toY: e.total,
                      color: Colors.brown[400],
                      width: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                )).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection() {
    if (controller.topProducts.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text('لا توجد مبيعات في هذا الشهر', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('🏆 أعلى 5 منتجات مبيعاً (حسب الإيراد)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...controller.topProducts.asMap().entries.map((entry) {
            final index = entry.key;
            final product = entry.value;

            IconData icon;
            Color iconColor;
            if (product.unitType == 'كيلو') {
              icon = Icons.grain;
              iconColor = Colors.brown;
            } else if (product.unitType == 'كوب') {
              icon = Icons.local_cafe;
              iconColor = Colors.blue;
            } else {
              icon = Icons.fastfood;
              iconColor = Colors.orange;
            }

            return Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    radius: 22,
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  title: Text(product.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${product.totalQuantity.toStringAsFixed(1)} ${product.unitType}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${product.totalAmount.toStringAsFixed(2)} ج.م',
                          style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index < controller.topProducts.length - 1) Divider(height: 0, color: Colors.grey[200]),
              ],
            );
          }),
        ],
      ),
    );
  }
}