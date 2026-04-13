import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled1/data/user_cubit/user_state.dart';
import '../repositories/users_repository.dart';

class UsersCubit extends Cubit<UsersState> {
  final UsersRepository repo;

  UsersCubit(this.repo) : super(UsersInitial()) {
    loadEmployees();
  }

  Future<void> loadEmployees() async {
    emit(UsersLoading());
    try {
      final employees = await repo.getAllEmployees();
      emit(UsersLoaded(employees));
    } catch (_) {
      emit(UsersError('فشل تحميل الموظفين'));
    }
  }

  Future<void> addEmployee({
    required String name,
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      await repo.addUser(
        name: name,
        username: username,
        password: password,
        role: role,
      );
      await loadEmployees();
    } catch (_) {
      emit(UsersError('فشل إضافة المستخدم'));
    }
  }

  Future<void> deleteEmployee(int id) async {
    try {
      await repo.deleteUser(id);
      await loadEmployees();
    } catch (_) {
      emit(UsersError('فشل الحذف'));
    }
  }
}
