import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/users_repository.dart';
import '../screens/home_screen.dart';

class LoginController extends GetxController {
  final repo = UsersRepository();

  // التحكم في الحقول
  final usernameCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();

  // متغيرات مراقبة
  var isLoading = false.obs;

  Future<void> login() async {
    if (usernameCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      Get.snackbar("تنبيه", "برجاء إدخال اسم المستخدم وكلمة المرور",
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.orange[100]);
      return;
    }

    try {
      isLoading(true);

      final user = await repo.login(
        usernameCtrl.text.trim(),
        passwordCtrl.text,
      );

      if (user != null) {
        // الانتقال للشاشة الرئيسية ومسح شاشة اللوجن من الـ Stack
        Get.offAll(() => HomeScreen(currentUser: user));
      } else {
        Get.snackbar("خطأ", "اسم المستخدم أو كلمة المرور غير صحيحة",
            backgroundColor: Colors.red[100], snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("خطأ", "حدث مشكلة في الاتصال: $e",
          backgroundColor: Colors.red[100], snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    super.onClose();
  }
}