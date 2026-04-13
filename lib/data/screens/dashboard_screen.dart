import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardRepository _repo = DashboardRepository();

  List<DailySale> dailySales = [];
  List<ProductSale> topProducts = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final sales = await _repo.getDailySales(now.month, now.year);
      final products = await _repo.getTopProducts(now.month, now.year);

      setState(() {
        dailySales = sales;
        topProducts = products;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "فشل في تحميل البيانات: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // حساب إجمالي اليوم من القائمة المجلوبة
    final totalSales = dailySales.fold<double>(0, (sum, e) => sum + e.total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        backgroundColor: Colors.brown,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAllData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.brown))
          : errorMessage != null
          ? Center(child: Text(errorMessage!))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // كارت إجمالي المبيعات
            _buildTotalSalesCard(totalSales),
            const SizedBox(height: 20),

            // الرسم البياني
            if (dailySales.isNotEmpty) _buildChartCard(),
            const SizedBox(height: 20),

            // قائمة أعلى المنتجات
            if (topProducts.isNotEmpty) _buildTopProductsCard(),
          ],
        ),
      ),
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

  Widget _buildChartCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 250,
          child: BarChart(
            BarChartData(
              maxY: dailySales.map((e) => e.total).reduce((a, b) => a > b ? a : b) * 1.2,
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
              barGroups: dailySales.map((e) {
                return BarChartGroupData(
                  x: int.parse(e.day),
                  barRods: [BarChartRodData(toY: e.total, color: Colors.brown, width: 15)],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopProductsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أعلى 5 منتجات مبيعًا', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Divider(),
            ...topProducts.map((p) => ListTile(
              leading: CircleAvatar(backgroundColor: Colors.brown[100], child: const Icon(Icons.coffee, color: Colors.brown)),
              title: Text(p.productName),
              trailing: Text('${p.totalQuantity.toStringAsFixed(1)} ${p.unitType}'),
            )),
          ],
        ),
      ),
    );
  }
}