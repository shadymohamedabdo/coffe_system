import 'package:flutter/material.dart';
import '../repositories/users_repository.dart';

class AddEmployeeScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const AddEmployeeScreen({super.key, required this.currentUser});

  @override
  State<AddEmployeeScreen> createState() => _AddEmployeeScreenState();
}

class _AddEmployeeScreenState extends State<AddEmployeeScreen> {
  // تعريف المستودع والتحكم
  final UsersRepository _repo = UsersRepository();
  final nameCtrl = TextEditingController();
  final userCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  List<Map<String, dynamic>> employees = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchEmployees(); // تحميل البيانات عند فتح الشاشة
  }

  // ميثود جلب البيانات من الداتا بيز
  Future<void> _fetchEmployees() async {
    setState(() => isLoading = true);
    try {
      final data = await _repo.getAllEmployees();
      setState(() {
        employees = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("خطأ في تحميل البيانات: $e");
    }
  }

  // ميثود الحذف
  Future<void> _deleteUser(int id) async {
    await _repo.deleteUser(id);
    _fetchEmployees(); // تحديث القائمة بعد الحذف
    _showSnackBar("تم حذف المستخدم بنجاح");
  }

  // ميثود الإضافة
  Future<void> _addNewUser(String name, String user, String pass, String role) async {
    await _repo.addUser(name: name, username: user, password: pass, role: role);
    _fetchEmployees(); // تحديث القائمة بعد الإضافة
    _showSnackBar("تم إضافة $name بنجاح");
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    // حماية الصفحة للأدمن فقط
    if (widget.currentUser['role'] != 'admin') {
      return const Scaffold(body: Center(child: Text('غير مصرح لك بالدخول')));
    }

    // تصفية القائمة بناءً على البحث
    final filteredList = employees.where((e) {
      return e['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('إدارة المستخدمين'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_alt_1),
            onPressed: () => _showAddEmployeeDialog(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // حقل البحث
            TextField(
              controller: searchCtrl,
              onChanged: (v) => setState(() => searchQuery = v),
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator(color: Colors.brown))
                  : filteredList.isEmpty
                  ? const Center(child: Text('لا يوجد مستخدمين حالياً'))
                  : ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, i) {
                  final emp = filteredList[i];
                  bool isMe = emp['id'] == widget.currentUser['id'];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: emp['role'] == 'admin' ? Colors.red : Colors.brown,
                        child: Icon(emp['role'] == 'admin' ? Icons.admin_panel_settings : Icons.person, color: Colors.white),
                      ),
                      title: Text(emp['name']),
                      subtitle: Text('${emp['username']} - ${emp['role']}'),
                      trailing: isMe
                          ? const Icon(Icons.star, color: Colors.amber) // علامة تميزك
                          : IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteUser(emp['id']),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEmployeeDialog() {
    String role = 'employee';
    nameCtrl.clear(); userCtrl.clear(); passCtrl.clear();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              title: const Text('إضافة مستخدم جديد'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'الاسم')),
                  TextField(controller: userCtrl, decoration: const InputDecoration(labelText: 'اسم المستخدم')),
                  TextField(controller: passCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'كلمة المرور')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: role,
                    items: const [
                      DropdownMenuItem(value: 'employee', child: Text('موظف')),
                      DropdownMenuItem(value: 'admin', child: Text('أدمن')),
                    ],
                    onChanged: (v) => setLocalState(() => role = v!),
                    decoration: const InputDecoration(labelText: 'الصلاحية'),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty && userCtrl.text.isNotEmpty) {
                      _addNewUser(nameCtrl.text, userCtrl.text, passCtrl.text, role);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}