import 'package:get/get.dart';
import '../screens/login_screen.dart';

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
    // الخروج ومسح كل الصفحات السابقة من الـ Stack
    Get.offAll(() => const LoginScreen());
  }
}