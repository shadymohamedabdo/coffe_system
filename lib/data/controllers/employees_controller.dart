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
      // assignAll = replace old data with new data
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

  Future<void> deleteUser(int id) async {
    try {
      employees.assignAll(await _repo.deleteUser(id));
      AppSnackbar.success("تم الحذف بنجاح");
    } catch (e) {
      AppSnackbar.error("حدث خطأ أثناء الحذف");
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