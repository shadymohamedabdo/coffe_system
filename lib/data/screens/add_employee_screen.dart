import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/employees_controller.dart';

class AddEmployeeScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  const AddEmployeeScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    // حقن الـ Controller
    final controller = Get.put(EmployeesController());

    final nameCtrl = TextEditingController();
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    // حماية الصفحة للأدمن فقط
    if (currentUser['role'] != 'admin') {
      return const Scaffold(body: Center(child: Text('غير مصرح لك بالدخول')));
    }

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => _showAddDialog(context, controller, nameCtrl, userCtrl, passCtrl),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // حقل البحث يغير قيمة searchQuery في الـ Controller
            TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              decoration: InputDecoration(
                labelText: 'بحث بالاسم...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator(color: Colors.brown));
                }
                if (controller.filteredList.isEmpty) {
                  return const Center(child: Text('لا يوجد مستخدمين حالياً'));
                }
                return ListView.builder(
                  itemCount: controller.filteredList.length,
                  itemBuilder: (context, i) {
                    final emp = controller.filteredList[i];
                    bool isMe = emp['id'] == currentUser['id'];
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: emp['role'] == 'admin' ? Colors.red : Colors.brown,
                          child: Icon(emp['role'] == 'admin' ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
                        ),
                        title: Text(emp['name']),
                        subtitle: Text('${emp['username']} - ${emp['role']}'),
                        trailing: isMe
                            ? const Icon(Icons.star, color: Colors.amber)
                            : IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => controller.deleteUser(emp['id']),
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddDialog(BuildContext context, EmployeesController controller, TextEditingController name, TextEditingController user, TextEditingController pass) {
    String role = 'employee';
    name.clear(); user.clear(); pass.clear();

    Get.dialog(
      AlertDialog(
        title: const Text('إضافة مستخدم جديد'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'الاسم')),
              TextField(controller: user, decoration: const InputDecoration(labelText: 'اسم المستخدم')),
              TextField(controller: pass, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: role,
                items: const [
                  DropdownMenuItem(value: 'employee', child: Text('موظف')),
                  DropdownMenuItem(value: 'admin', child: Text('أدمن')),
                ],
                onChanged: (v) => role = v!,
                decoration: const InputDecoration(labelText: 'الصلاحية'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (name.text.isNotEmpty && user.text.isNotEmpty) {
                controller.addNewUser(name.text, user.text, pass.text, role);
                Get.back();
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}