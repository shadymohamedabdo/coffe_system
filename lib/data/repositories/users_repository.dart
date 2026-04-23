import '../database_helper.dart';

class UsersRepository {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Map<String, dynamic>>> getAllEmployees() async {
    final db = await dbHelper.database;
    return await db.query('users', orderBy: 'name ASC');
  }

  Future<void> addUser({
    required String name,
    required String username,
    required String password,
    required String role,
  }) async {
    final db = await dbHelper.database;
    await db.insert('users', {
      'name': name,
      'username': username,
      'password': password,
      'role': role,
    });
  }

  // ✅ إرجاع bool للإشارة إلى نجاح الحذف
  Future<bool> deleteUser(int id) async {
    final db = await dbHelper.database;
    final result = await db.delete('users', where: 'id = ?', whereArgs: [id]);
    return result > 0;
  }

  Future<Map<String, dynamic>?> login(String username, String password) async {
    final db = await dbHelper.database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }
}