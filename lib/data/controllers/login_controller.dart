import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../binding.dart';
import '../constants.dart';
import '../repositories/users_repository.dart';
import '../screens/home_screen.dart';

class LoginController extends GetxController {
  final UsersRepository repo = UsersRepository();

  // Controllers
  final TextEditingController usernameCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();

  // Focus
  final FocusNode userFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  // Loading state
  var isLoading = false.obs;

  Future<void> login() async {
    // Validation
    if (usernameCtrl.text.isEmpty || passwordCtrl.text.isEmpty) {
      AppSnackbar.warning("برجاء إدخال اسم المستخدم وكلمة المرور!");
      return;
    }

    try {
      isLoading(true);

      final user = await repo.login(
        usernameCtrl.text.trim(),
        passwordCtrl.text.trim(),
      );

      if (user != null) {
        // Navigation to Home
        Get.offAll(
              () => const HomeScreen(),
          arguments: user,
          binding: HomeBinding(),
        );
      } else {
        AppSnackbar.error('اسم المستخدم أو كلمة المرور غير صحيحة');
      }
    } catch (e) {
      // Error handling (رسالة عامة)
      AppSnackbar.error('حدث خطأ، حاول مرة أخرى');
    } finally {
      isLoading(false);
    }
  }

  @override
  void onClose() {
    // Dispose
    usernameCtrl.dispose();
    passwordCtrl.dispose();
    userFocus.dispose();
    passwordFocus.dispose();
    super.onClose();
  }
}