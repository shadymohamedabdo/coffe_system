import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/users_repository.dart';

class EmployeesController extends GetxController {
  final UsersRepository _repo = UsersRepository();

  // نستخدم Rx للأشياء التي تتغير
  var employees = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var searchQuery = "".obs;

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
      Get.snackbar("خطأ", "فشل تحميل البيانات: $e", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading(false);
    }
  }

  // تصفية القائمة بناءً على البحث (Computed Property)
  List<Map<String, dynamic>> get filteredList {
    if (searchQuery.isEmpty) return employees;
    return employees.where((e) {
      return e['name'].toString().toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  // الحذف
  Future<void> deleteUser(int id) async {
    await _repo.deleteUser(id);
    fetchEmployees();
    Get.snackbar("نجاح", "تم حذف المستخدم بنجاح", backgroundColor: Colors.red[100]);
  }

  // الإضافة
  Future<void> addNewUser(String name, String user, String pass, String role) async {
    await _repo.addUser(name: name, username: user, password: pass, role: role);
    fetchEmployees();
    Get.snackbar("تم", "تم إضافة $name بنجاح", backgroundColor: Colors.green[100]);
  }
}