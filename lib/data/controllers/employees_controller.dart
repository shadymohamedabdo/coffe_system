import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../repositories/users_repository.dart';

class EmployeesController extends GetxController {
  final UsersRepository _repo = UsersRepository();

  var employees = <Map<String, dynamic>>[].obs;
  var isLoading = true.obs;
  var searchQuery = "".obs;

  final nameCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchEmployees();
  }

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

  List<Map<String, dynamic>> get filteredList {
    if (searchQuery.isEmpty) return employees;
    return employees.where((e) {
      return e['name'].toString().toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  // ✅ دالة الحذف المعدلة (تتحقق من النجاح)
  Future<void> deleteUser(int id) async {
    try {
      final deleted = await _repo.deleteUser(id);
      if (deleted) {
        employees.removeWhere((emp) => emp['id'] == id);
        AppSnackbar.success("تم حذف المستخدم بنجاح");
      } else {
        AppSnackbar.error("المستخدم غير موجود");
      }
    } catch (e) {
      AppSnackbar.error("حدث خطأ أثناء الحذف");
      print("Error deleting user: $e");
    }
  }

  Future<void> addNewUser(String name, String user, String pass, String role) async {
    try {
      await _repo.addUser(name: name, username: user, password: pass, role: role);
      await fetchEmployees();
      AppSnackbar.success("تم إضافة $name بنجاح");
    } catch (e) {
      AppSnackbar.error("فشل الإضافة: $e");
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    userCtrl.dispose();
    passCtrl.dispose();
    super.onClose();
  }
}