import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: 400,
            child: Card(
              elevation: 10,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.coffee_rounded, size: 80, color: Colors.brown),
                    const SizedBox(height: 10),
                    const Text(
                      'تسجيل الدخول',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                    const SizedBox(height: 30),

                    // حقل اسم المستخدم
                    TextField(
                      controller: controller.usernameCtrl,
                      focusNode: controller.userFocus, // استخدام الـ Node من الكنترولر
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'اسم المستخدم',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      // التنقل السلس للحقل التالي عند الضغط على Enter
                      onSubmitted: (_) {
                        controller.passwordFocus.requestFocus();
                      },
                    ),
                    const SizedBox(height: 16),

                    // حقل كلمة المرور
                    TextField(
                      controller: controller.passwordCtrl,
                      focusNode: controller.passwordFocus, // استخدام الـ Node من الكنترولر
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'كلمة المرور',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      // تنفيذ ميثود تسجيل الدخول مباشرة عند الضغط على Enter
                      onSubmitted: (_) => controller.login(),
                    ),
                    const SizedBox(height: 30),

                    // زر تسجيل الدخول مع مراقبة الحالة
                    Obx(() => SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value ? null : controller.login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown[700],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: controller.isLoading.value
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('دخول النظام', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}