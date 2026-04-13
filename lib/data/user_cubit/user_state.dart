abstract class UsersState {}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<Map<String, dynamic>> employees;
  UsersLoaded(this.employees);
}

class UsersError extends UsersState {
  final String message;
  UsersError(this.message);
}
