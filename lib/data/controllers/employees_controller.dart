import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../repositories/users_repository.dart';

class EmployeesController extends GetxController {
  final UsersRepository _repo = UsersRepository();

  // 📌 قائمة الموظفين
  var employees = <Map<String, dynamic>>[].obs;

  // 📌 حالة التحميل
  var isLoading = true.obs;

  // 📌 نص البحث
  var searchQuery = "".obs;

  // 📌 Controllers للفورم
  final nameCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchEmployees(); // تحميل البيانات أول ما الصفحة تفتح
  }

  // =====================================================
  // 🟢 تحميل كل الموظفين من الداتابيز
  // =====================================================
  Future<void> fetchEmployees() async {
    try {
      isLoading(true);

      final data = await _repo.getAllEmployees();

      // replace old data with new data
      employees.assignAll(data);
    } catch (e) {
      AppSnackbar.error("فشل تحميل البيانات: $e");
    } finally {
      isLoading(false);
    }
  }

  // =====================================================
  // 🔍 فلترة الموظفين حسب البحث
  // =====================================================
  List<Map<String, dynamic>> get filteredList {
    if (searchQuery.isEmpty) return employees;

    return employees.where((e) {
      return e['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  // =====================================================
  // 🗑️ حذف موظف
  // =====================================================
  Future<void> deleteUser(int id) async {
    try {
      employees.assignAll(await _repo.deleteUser(id));
      AppSnackbar.success("تم الحذف بنجاح");
    } catch (e) {
      AppSnackbar.error("حدث خطأ أثناء الحذف");
    }
  }

  // =====================================================
  // ➕ إضافة موظف جديد (🔥 المهمة هنا)
  // =====================================================
  Future<bool> addNewUser(
      String name,
      String user,
      String pass,
      String role,
      ) async {
    // 🔴 1. منع تكرار اسم المستخدم
    final existing =
    employees.firstWhereOrNull((e) => e['username'] == user);

    if (existing != null) {
      AppSnackbar.error("اسم المستخدم '$user' موجود بالفعل");
      return false;
    }

    try {
      // 🔵 2. إضافة المستخدم في الداتابيز
      await _repo.addUser(
        name: name,
        username: user,
        password: pass,
        role: role,
      );

      // 🔄 3. تحديث القائمة
      await fetchEmployees();

      AppSnackbar.success("تم إضافة $name بنجاح");

      return true; // ✅ نجاح
    } catch (e) {
      AppSnackbar.error("فشل الإضافة: $e");
      return false; // ❌ فشل
    }
  }

  // =====================================================
  // 🧹 تنظيف الControllers
  // =====================================================
  @override
  void onClose() {
    nameCtrl.dispose();
    userCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }
}