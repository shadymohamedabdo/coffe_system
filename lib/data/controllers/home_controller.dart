import 'package:get/get.dart';
import '../screens/login_screen.dart';
import 'login_controller.dart';

class HomeController extends GetxController {
  // استقبال بيانات المستخدم اللي جاية من صفحة اللوجن
  late Map<String, dynamic> currentUser;

  @override
  void onInit() {
    super.onInit();
    // Get.arguments هي الطريقة الأنظف لاستلام البيانات في GetX
    currentUser = Get.arguments ?? {};
  }

  bool get isAdmin => currentUser['role'] == 'admin';
  String get displayName => currentUser['name'] ?? currentUser['username'] ?? 'المستخدم';

  void logout() {
    // 1. الوصول للـ LoginController ومسح التكست
    // استبدل LoginController بالاسم الحقيقي عندك
    if (Get.isRegistered<LoginController>()) {
      final loginCtrl = Get.find<LoginController>();
      loginCtrl.usernameCtrl.clear();    // امسح حقل الايميل
      loginCtrl.passwordCtrl.clear(); // امسح حقل الباسورد
    }

    // 2. الخروج لصفحة اللوجين
    Get.offAll(() => const LoginScreen());
  }
}