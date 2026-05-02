import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../controllers/employees_controller.dart';

class AddEmployeeScreen extends GetView<EmployeesController> {
  final Map<String, dynamic> currentUser;
  const AddEmployeeScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    if (currentUser['role'] != 'admin') {
      return const Scaffold(body: Center(child: Text('غير مصرح لك بالدخول')));
    }
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('إدارة فريق العمل',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.brown[800],
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.brown[700],
        onPressed: () => _showAddDialog(controller),
        label: const Text('إضافة موظف', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: TextField(
                onChanged: (v) => controller.searchQuery.value = v,
                decoration: InputDecoration(
                  hintText: 'ابحث عن زميل عمل...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  prefixIcon: Icon(Icons.search, color: Colors.brown[300]),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: controller.filteredList.length,
                itemBuilder: (context, i) {
                  final emp = controller.filteredList[i];
                  bool isMe = emp['id'] == currentUser['id'];
                  return _buildEmployeeCard(emp, isMe);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> emp, bool isMe) {
    bool isAdmin = emp['role'] == 'admin';
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isMe ? Colors.brown.withValues(alpha: 0.3) : Colors.transparent),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: isAdmin ? Colors.red[50] : Colors.brown[50],
            child: Icon(isAdmin ? Icons.admin_panel_settings : Icons.person,
                color: isAdmin ? Colors.red[400] : Colors.brown[400], size: 30),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emp['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isAdmin ? Colors.red[100] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(isAdmin ? 'مدير النظام' : 'باريستا',
                      style: TextStyle(fontSize: 11, color: isAdmin ? Colors.red[700] : Colors.grey[700])),
                ),
              ],
            ),
          ),
          if (isMe)
            const Chip(label: Text('أنت', style: TextStyle(fontSize: 10)), backgroundColor: Colors.amberAccent)
          else
            IconButton(
              icon: Icon(Icons.delete_sweep_outlined, color: Colors.red[300]),
              onPressed: () => _confirmDelete(emp['id'] as int, controller),
            ),
        ],
      ),
    );
  }
  void _showAddDialog(EmployeesController controller) {
    String role = 'employee';
    controller.nameCtrl.clear();
    controller.userCtrl.clear();
    controller.passCtrl.clear();
    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'إضافة موظف جديد',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  _buildPopupTextField(
                    controller.nameCtrl,
                    'الاسم بالكامل',
                    Icons.person_outline,
                  ),

                  _buildPopupTextField(
                    controller.userCtrl,
                    'اسم المستخدم',
                    Icons.alternate_email,
                  ),

                  _buildPopupTextField(
                    controller.passCtrl,
                    'كلمة المرور',
                    Icons.lock_outline,
                    isPass: true,
                  ),

                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    initialValue: role,
                    items: const [
                      DropdownMenuItem(
                        value: 'employee',
                        child: Text('باريستا (موظف)'),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text('مدير (أدمن)'),
                      ),
                    ],
                    onChanged: (v) => role = v!,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.brown[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      onPressed: () {
                        final name = controller.nameCtrl.text.trim();
                        final username = controller.userCtrl.text.trim();
                        final password = controller.passCtrl.text.trim();

                        if (name.isEmpty || username.isEmpty || password.isEmpty) {
                          AppSnackbar.error(
                            "من فضلك اكمل جميع البيانات المطلوبة",
                          );
                          return;
                        }

                        controller.addNewUser(name, username, password, role);
                        Get.back();
                      },                      child: const Text(
                        'تأكيد الحفظ',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true, // يقفل لما تضغط بره
    );
  }
  Widget _buildPopupTextField(TextEditingController ctrl, String hint, IconData icon, {bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.brown[300]),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        ),
      ),
    );
  }
  void _confirmDelete(int id, EmployeesController controller) {
    Get.defaultDialog(
      title: "تنبيه",
      titleStyle: const TextStyle(fontWeight: FontWeight.bold),
      middleText: "هل تريد حقاً استبعاد هذا الموظف من الفريق؟",
      textConfirm: "حذف",
      textCancel: "تراجع",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red[400]!,
      radius: 15,
      onConfirm: () {
        controller.deleteUser(id);
        Get.back();
      },
    );
  }
}