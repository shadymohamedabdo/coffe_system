import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants.dart';
import '../controllers/employees_controller.dart';

class AddEmployeeScreen extends GetView<EmployeesController> {
  final Map<String, dynamic> currentUser;

  const AddEmployeeScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    // 🔴 منع غير الأدمن من الدخول
    if (currentUser['role'] != 'admin') {
      return const Scaffold(
        body: Center(child: Text('غير مصرح لك بالدخول')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],

      // ================= AppBar =================
      appBar: AppBar(
        title: const Text(
          'إدارة فريق العمل',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        backgroundColor: Colors.brown[800],
      ),

      // ================= زر إضافة موظف =================
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.brown[700],
        onPressed: () => _showAddDialog(controller),
        label: const Text('إضافة موظف'),
        icon: const Icon(Icons.add),
      ),

      // ================= Body =================
      body: Column(
        children: [
          const SizedBox(height: 10),

          // 🔍 Search
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                hintText: 'ابحث عن موظف...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ================= List =================
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                itemCount: controller.filteredList.length,
                itemBuilder: (context, i) {
                  final emp = controller.filteredList[i];
                  final isMe = emp['id'] == currentUser['id'];

                  return _buildEmployeeCard(emp, isMe);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // 🟢 Card عرض الموظف
  // =====================================================
  Widget _buildEmployeeCard(Map<String, dynamic> emp, bool isMe) {
    final isAdmin = emp['role'] == 'admin';

    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        // 🔵 تمييز المستخدم الحالي
        border: Border.all(
          color: isMe ? Colors.brown.withValues(alpha: 0.3) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          // 🟣 Avatar
          CircleAvatar(
            backgroundColor: isAdmin ? Colors.red[50] : Colors.brown[50],
            child: Icon(
              isAdmin ? Icons.admin_panel_settings : Icons.person,
              color: isAdmin ? Colors.red : Colors.brown,
            ),
          ),

          const SizedBox(width: 10),

          // 👤 بيانات الموظف
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emp['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(isAdmin ? "مدير" : "موظف"),
              ],
            ),
          ),

          // 🟡 لو المستخدم الحالي
          if (isMe)
            const Chip(label: Text("أنت"))

          // 🗑️ زر حذف
          else
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(emp['id'], controller),
            ),
        ],
      ),
    );
  }

  // =====================================================
  // 🟢 Dialog إضافة موظف
  // =====================================================
  void _showAddDialog(EmployeesController controller) {
    // 🔵 Reset fields
    controller.nameCtrl.clear();
    controller.userCtrl.clear();
    controller.passCtrl.clear();

    // 🔴 Reactive role (أفضل من String عادي)
    final role = 'employee'.obs;

    Get.dialog(
      Center(
        child: Material(
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "إضافة موظف",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                // 👤 الاسم
                _field(controller.nameCtrl, "الاسم"),

                // 👤 username
                _field(controller.userCtrl, "اسم المستخدم"),

                // 🔒 password
                _field(controller.passCtrl, "كلمة المرور", isPass: true),

                const SizedBox(height: 10),

                // 👨‍💼 role dropdown
                Obx(() {
                  return DropdownButton<String>(
                    value: role.value,
                    items: const [
                      DropdownMenuItem(
                        value: 'employee',
                        child: Text("موظف"),
                      ),
                      DropdownMenuItem(
                        value: 'admin',
                        child: Text("أدمن"),
                      ),
                    ],
                    onChanged: (v) => role.value = v!,
                  );
                }),

                const SizedBox(height: 20),

                // ================= Save Button =================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // 🔴 Validation داخل الديالوج
                      if (controller.nameCtrl.text.isEmpty ||
                          controller.userCtrl.text.isEmpty ||
                          controller.passCtrl.text.isEmpty) {
                        AppSnackbar.error("اكمل البيانات");
                        return;
                      }

                      // 🔵 استنى النتيجة قبل ما تقفل
                      final success = await controller.addNewUser(
                        controller.nameCtrl.text,
                        controller.userCtrl.text,
                        controller.passCtrl.text,
                        role.value,
                      );

                      if (success) {
                        Get.back(); // يقفل فقط لو نجح
                      }
                    },
                    child: const Text("حفظ"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // 🟢 TextField reusable
  // =====================================================
  Widget _field(TextEditingController c, String hint,
      {bool isPass = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        obscureText: isPass,
        decoration: InputDecoration(
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // 🟢 Delete confirmation
  // =====================================================
  void _confirmDelete(int id, EmployeesController controller) {
    Get.defaultDialog(
      title: "حذف",
      middleText: "هل تريد حذف الموظف؟",
      textConfirm: "نعم",
      textCancel: "لا",
      onConfirm: () {
        controller.deleteUser(id);
        Get.back();
      },
    );
  }
}