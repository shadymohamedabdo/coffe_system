import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';

// الشاشة الرئيسية لعرض الإحصائيات
class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // لون خلفية خفيف
      backgroundColor: Colors.grey[100],

      // ================= AppBar =================
      appBar: AppBar(
        title: const Text(
          'لوحة الإحصائيات',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        elevation: 0,

        // هنا بنحط الفلتر (شهر + سنة)
        actions: [_buildFilterHeader()],
      ),

      // ================= Body =================
      body: Obx(() {

        // لو البيانات بتتحمل
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.brown),
          );
        }

        // لو في Error
        if (controller.hasError.value) {
          return _buildErrorWidget();
        }

        // عرض البيانات
        return RefreshIndicator(

          // pull to refresh
          onRefresh: () => controller.loadAllData(),

          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),

            child: Column(
              children: [

                // كارت الإجمالي
                _buildSummaryCard(),

                const SizedBox(height: 20),

                // الشارت
                _buildChartSection(),

                const SizedBox(height: 20),

                // أفضل المنتجات
                _buildTopProductsSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ================= فلتر الشهر والسنة =================
  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),

      child: Row(
        children: [

          // Dropdown الشهر
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),

            child: DropdownButton<int>(
              value: controller.selectedMonth.value,
              dropdownColor: Colors.brown[700],
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),

              // إنشاء 12 شهر
              items: List.generate(12, (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(_getMonthName(i + 1)),
              )),

              // عند تغيير الشهر
              onChanged: (val) {
                if (val != null) controller.changeMonth(val);
              },
            ),
          ),

          const SizedBox(width: 8),

          // Dropdown السنة
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),

            child: DropdownButton<int>(
              value: controller.selectedYear.value,
              dropdownColor: Colors.brown[700],
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),

              // السنوات المتاحة
              items: [2024, 2025, 2026, 2027]
                  .map((y) => DropdownMenuItem(
                value: y,
                child: Text('$y'),
              ))
                  .toList(),

              // عند تغيير السنة
              onChanged: (val) {
                if (val != null) controller.changeYear(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  // تحويل رقم الشهر لاسم
  String _getMonthName(int month) {
    const months = [
      'يناير','فبراير','مارس','أبريل','مايو','يونيو',
      'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'
    ];
    return months[month - 1];
  }

  // ================= Error UI =================
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // أيقونة خطأ
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),

          const SizedBox(height: 16),

          // رسالة الخطأ
          Text(
            controller.errorMessage.value,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // زر إعادة المحاولة
          ElevatedButton(
            onPressed: () => controller.loadAllData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  // ================= كارت الإجمالي =================
  Widget _buildSummaryCard() {

    // TweenAnimation علشان يعمل أنيميشن للرقم
    return TweenAnimationBuilder(
      tween: Tween<double>(
        begin: 0,
        end: controller.totalSales,
      ),
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
                color: Colors.brown.withValues(alpha: 0.3),
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

              // الرقم المتحرك
              Text(
                '${value.toStringAsFixed(2)} ج.م',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              // الشهر + السنة
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
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

  // ================= الشارت =================
  Widget _buildChartSection() {

    // لو مفيش بيانات
    if (controller.dailySales.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
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

          // الرسم البياني
          SizedBox(
            height: 220,
            child: BarChart(
              BarChartData(

                // أعلى قيمة في الشارت
                maxY: controller.maxDailySales.value,

                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),

                // المحاور
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

                  // محور Y
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        );
                      },
                    ),
                  ),

                  // محور X (الأيام)
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {

                        // عرض كل يومين بس لتقليل الزحمة
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

                // الأعمدة
                barGroups: controller.dailySales.map((e) {
                  return BarChartGroupData(
                    x: e.day,
                    barRods: [
                      BarChartRodData(
                        toY: e.total,
                        color: Colors.brown[400],
                        width: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= أفضل المنتجات =================
  Widget _buildTopProductsSection() {

    // لو مفيش بيانات
    if (controller.topProducts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        child: const Text(
          'لا توجد مبيعات في هذا الشهر',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            '🏆 أعلى 5 منتجات مبيعاً',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // عرض المنتجات
          ...controller.topProducts.map((product) {
            return ListTile(

              // اسم المنتج
              title: Text(product.productName),

              // الكمية
              subtitle: Text('${product.totalQuantity} ${product.unitType}'),

              // الإيراد
              trailing: Text('${product.totalAmount} ج.م'),
            );
          }),
        ],
      ),
    );
  }
}