import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../repositories/users_repository.dart';

class EmployeesController extends GetxController {
  final UsersRepository _repo = UsersRepository();

  // 1. المتغيرات والملاحظات
  var employees = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var searchQuery = "".obs;

  // 2. الكنترولرز هنا لضمان الـ Performance والـ Memory Management
  final nameCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

  // جلب البيانات
  Future<void> fetchEmployees() async {
    try {
      isLoading(true);
      final data = await _repo.getAllEmployees();
      employees.assignAll(data);
    } catch (e) {
      AppSnackbar.error("فشل تحميل البيانات: $e");
    } finally {
      isLoading(false);
    }
  }

  // تصفية البحث (Computed Property)
  List<Map<String, dynamic>> get filteredList {
    if (searchQuery.isEmpty) return employees;
    return employees.where((e) {
      return e['name'].toString().toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  // الحذف (Memory Update لسرعة خرافية)
  Future<void> deleteUser(int id) async {
    try {
      await _repo.deleteUser(id);
      employees.removeWhere((emp) => emp['id'] == id); // تحديث الميموري فوراً
      AppSnackbar.error('تم حذف المستخدم بنجاح');
    } catch (e) {
      AppSnackbar.error("فشل الحذف: $e");
    }
  }

  // الإضافة
  Future<void> addNewUser(String name, String user, String pass, String role) async {
    try {
      await _repo.addUser(name: name, username: user, password: pass, role: role);
      await fetchEmployees(); // تحديث القائمة بعد الإضافة
      AppSnackbar.success("تم إضافة $name بنجاح");
    } catch (e) {
      AppSnackbar.error("فشل الإضافة: $e");
    }
  }

  @override
  void onClose() {
    // تنظيف الذاكرة
    nameCtrl.dispose();
    userCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }
}