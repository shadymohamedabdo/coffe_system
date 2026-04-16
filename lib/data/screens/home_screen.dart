import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
// استيراد الشاشات الخاصة بك
import 'add_sale_screen.dart';
import 'shift_report_screen.dart';
import 'monthly_report.dart';
import 'dashboard_screen.dart';
import 'shift_screen.dart';
import 'products_screen.dart';
import 'add_employee_screen.dart';
import 'profit_calculator.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(' محل البن'),
        centerTitle: true,
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل خروج',
            onPressed: () => controller.logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: isLargeScreen ? 4 : 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: isLargeScreen ? 1.8 : 1.4,
          children: [
            // زر تسجيل البيع
            _buildMenuItem(
              label: 'تسجيل بيع',
              icon: Icons.add_shopping_cart,
              color: Colors.green[700]!,
              onTap: () => Get.to(() => AddSaleScreen(currentUser: controller.currentUser)),
              isMain: true,
            ),

            _buildMenuItem(
              label: 'تقرير الشيفت',
              icon: Icons.receipt_long,
              color: Colors.orange[600]!,
              onTap: () => Get.to(() => ShiftReportScreen(currentUser: controller.currentUser)),
            ),

            if (controller.isAdmin) ...[
              _buildMenuItem(
                label: 'التقرير الشهري',
                icon: Icons.calendar_month,
                color: Colors.teal[600]!,
                onTap: () => Get.to(() => const MonthlyReportScreen()),
              ),
              _buildMenuItem(
                label: 'حاسبة صافي الربح',
                icon: Icons.calculate,
                color: Colors.teal[500]!,
                onTap: () => Get.to(() => const ProfitCalculatorScreen()),
              ),
              _buildMenuItem(
                label: 'لوحة التحكم',
                icon: Icons.dashboard,
                color: Colors.blue[700]!,
                onTap: () => Get.to(() => const DashboardScreen()),
              ),
              _buildMenuItem(
                label: 'إدارة الشيفتات',
                icon: Icons.access_time,
                color: Colors.red[600]!,
                onTap: () => Get.to(() => const ShiftScreen()),
              ),
              _buildMenuItem(
                label: 'إدارة المنتجات',
                icon: Icons.coffee,
                color: Colors.brown[600]!,
                onTap: () => Get.to(() => const ProductsScreen()),
              ),
              _buildMenuItem(
                label: 'إدارة الموظفين',
                icon: Icons.people,
                color: Colors.purple[600]!,
                onTap: () => Get.to(() => AddEmployeeScreen(currentUser: controller.currentUser)),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.brown[700],
        child: Text(
          'مرحباً، ${controller.displayName}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isMain = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.95), color.withOpacity(0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isMain ? 56 : 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: isMain ? 20 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}