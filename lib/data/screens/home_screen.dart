
import 'package:flutter/material.dart';
import 'package:untitled1/data/screens/profit_calculator.dart';
import 'add_sale_screen.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'monthly_report.dart';
import 'shift_report_screen.dart';
import 'shift_screen.dart';
import 'products_screen.dart';
import 'add_employee_screen.dart';

class HomeScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;

  const HomeScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final bool isAdmin = currentUser['role'] == 'admin';
    final bool isLargeScreen = MediaQuery.of(context).size.width > 600;

    // زر تسجيل البيع - الأهم
    final Widget mainSaleButton = _buildMenuItem(
      label: 'تسجيل بيع',
      icon: Icons.add_shopping_cart,
      color: Colors.green[700]!,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddSaleScreen(currentUser: currentUser),
          ),
        );
      },
      isMain: true, // عشان يبقى أكبر وأبرز
    );

    // باقي الأزرار
    final List<Widget> otherButtons = [
      _buildMenuItem(
        label: 'تقرير الشيفت',
        icon: Icons.receipt_long,
        color: Colors.orange[600]!,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ShiftReportScreen(currentUser: currentUser),
            ),
          );
        },
      ),
      if (isAdmin)
        _buildMenuItem(
          label: 'التقرير الشهري',
          icon: Icons.calendar_month,
          color: Colors.teal[600]!,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MonthlyReportScreen()),
          ),
        ),
      if (isAdmin)
        _buildMenuItem(
          label: 'حاسبة صافي الربح', // ← الزر الجديد
          icon: Icons.calculate,
          color: Colors.teal[500]!,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfitCalculatorScreen()),
          ),
        ),
      if (isAdmin)
        _buildMenuItem(
          label: 'لوحة التحكم',
          icon: Icons.dashboard,
          color: Colors.blue[700]!,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DashboardScreen()),
          ),
        ),
      if (isAdmin)
        _buildMenuItem(
          label: 'إدارة الشيفتات',
          icon: Icons.access_time,
          color: Colors.red[600]!,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ShiftScreen()),
          ),
        ),
      if (isAdmin)
        _buildMenuItem(
          label: 'إدارة المنتجات',
          icon: Icons.coffee,
          color: Colors.brown[600]!,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProductsScreen()),
          ),
        ),
      if (isAdmin)
        _buildMenuItem(
          label: 'إدارة الموظفين',
          icon: Icons.people,
          color: Colors.purple[600]!,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEmployeeScreen(currentUser: currentUser),
            ),
          ),
        ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام POS - محل البن'),
        centerTitle: true,
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل خروج',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.custom(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: isLargeScreen ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: isLargeScreen ? 1.8 : 1.4,
          ),
          childrenDelegate: SliverChildListDelegate([
            ...otherButtons,
            if (otherButtons.length % 2 != 0 && !isLargeScreen)
              const SizedBox.shrink(),
            Center(child: mainSaleButton),
          ]),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: Colors.brown[700],
        child: Text(
          'مرحباً، ${currentUser['name'] ?? currentUser['username']}',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
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
    final double iconSize = isMain ? 64 : 48;
    final double fontSize = isMain ? 22 : 18;
    final EdgeInsets padding = isMain
        ? const EdgeInsets.symmetric(vertical: 24, horizontal: 32)
        : const EdgeInsets.all(16);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.95),
              color.withOpacity(0.75),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: iconSize, color: Colors.white),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
