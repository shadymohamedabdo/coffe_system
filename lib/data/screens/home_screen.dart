import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../binding.dart';
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
      // تجعل المحتوى يمتد خلف الـ AppBar ليعطي شكلاً جمالياً بالخلفية
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'بيت البن ',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // شفاف لتظهر الخلفية
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: IconButton(
              icon: const CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.logout, color: Colors.white, size: 20),
              ),
              tooltip: 'تسجيل خروج',
              onPressed: () => controller.logout(),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. الصورة الخلفية
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/coffe.png'), // المسار الذي حددته
                fit: BoxFit.cover,
              ),
            ),
          ),
          // 2. طبقة تعتيم (Overlay) لجعل الأزرار واضحة
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.6),
                  Colors.brown[900]!.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          // 3. شبكة الأزرار
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: isLargeScreen ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isLargeScreen ? 1.6 : 1.2,
                children: [
                  _buildMenuItem(
                    label: 'تسجيل بيع',
                    icon: Icons.add_shopping_cart_rounded,
                    color: Colors.greenAccent[700]!,
                    onTap: () => Get.to(() => AddSaleScreen(currentUser: controller.currentUser)),
                    isMain: true,
                  ),
                  _buildMenuItem(
                    label: 'تقرير الشيفت',
                    icon: Icons.receipt_long_rounded,
                    color: Colors.orangeAccent[400]!,
                    onTap: () => Get.to(() => ShiftReportScreen(currentUser: controller.currentUser),binding: ShiftReportBinding()),
                  ),
                  if (controller.isAdmin) ...[
                    _buildMenuItem(
                      label: 'التقرير الشهري',
                      icon: Icons.calendar_month_rounded,
                      color: Colors.tealAccent[400]!,
                      onTap: () => Get.to(() =>  MonthlyReportScreen(),binding: MonthlyReportBinding()),
                    ),
                    _buildMenuItem(
                      label: 'حاسبة الأرباح',
                      icon: Icons.calculate_rounded,
                      color: Colors.lightBlueAccent,
                      onTap: () => Get.to(() => const ProfitCalculatorScreen(),binding: CalculatorBinding()),
                    ),
                    _buildMenuItem(
                      label: 'الاحصائيات',
                      icon: Icons.dashboard_rounded,
                      color: Colors.blueAccent[100]!,
                      onTap: () => Get.to(() => const DashboardScreen(),binding: DashboardBinding()),
                    ),
                    _buildMenuItem(
                      label: 'إدارة الشيفتات',
                      icon: Icons.history_toggle_off_rounded,
                      color: Colors.redAccent[100]!,
                      // نمرر اسم المستخدم الحالي للـ ShiftScreen
                      onTap: () => Get.to(
                              () => ShiftScreen(currentUserName: controller.displayName),
                          binding: ShiftBinding()
                      ),
                    ),
                    _buildMenuItem(
                      label: 'إدارة المنتجات',
                      icon: Icons.coffee_rounded,
                      color: Colors.brown[200]!,
                      onTap: () => Get.to(() => const ProductsScreen(),binding: ProductsBinding()),
                    ),
                    _buildMenuItem(
                      label: 'إدارة الموظفين',
                      icon: Icons.badge_rounded,
                      color: Colors.purpleAccent[100]!,
                      onTap: () => Get.to(() => AddEmployeeScreen(currentUser: controller.currentUser),binding: EmployeesBinding()),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // ويدجت زر القائمة المطور بتصميم زجاجي
  Widget _buildMenuItem({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isMain = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1), // تأثير زجاجي
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isMain ? 50 : 38, color: color),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: isMain ? 18 : 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: const [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // شريط سفلي أنيق
  Widget _buildBottomBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.brown[900]!.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Center(
        child: Text(
          'مرحباً بك: ${controller.displayName}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}