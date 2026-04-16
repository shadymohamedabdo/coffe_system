import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../repositories/users_repository.dart';
import '../screens/home_screen.dart';
import 'home_controller.dart';

class LoginController extends GetxController {
  final repo = UsersRepository();

  // التحكم في الحقول
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // إدارة التركيز (Focus Management) لتحسين الأداء والمساحة
  final FocusNode userFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  // متغيرات مراقبة
  var isLoading = false.obs;

  Future<void> login() async {
    if (usernameCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      AppSnackbar.warning("برجاء إدخال اسم المستخدم وكلمة المرور!");
      return;
    }

    try {
      isLoading(true);

      final user = await repo.login(
        usernameCtrl.text.trim(),
        passwordCtrl.text,
      );

      if (user != null) {
// 1. نحقن الكنترولر بتاع الرئيسية (لو مش محقون في الـ main)
        Get.lazyPut(() => HomeController());

        // 2. ننتقل للشاشة بدون تمرير باراميتر في القوسين، ونبعته في الـ arguments
        Get.offAll(() => const HomeScreen(), arguments: user);      } else {
        AppSnackbar.error('اسم المستخدم أو كلمة المرور غير صحيحة');
      }
    } catch (e) {
      AppSnackbar.error('حدث مشكلة في الاتصال: $e');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    // تنظيف الذاكرة فور إغلاق الشاشة لمنع الـ Memory Leak
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    userFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}