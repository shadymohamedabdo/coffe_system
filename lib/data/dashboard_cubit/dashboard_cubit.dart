import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../repositories/dashboard_repository.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DashboardRepository repo;
  late final StreamSubscription refreshSub;

  DashboardCubit(this.repo, ) : super(DashboardInitial()) {
    loadData();

  }

  Future<void> loadData() async {
    emit(DashboardLoading());
    try {
      final dailySales = await repo.getDailySales(
          DateTime.now().month, DateTime.now().year);
      final topProducts = await repo.getTopProducts(
          DateTime.now().month, DateTime.now().year);
      emit(DashboardLoaded(dailySales: dailySales, topProducts: topProducts));
    } catch (e) {
      emit(DashboardError('فشل تحميل البيانات: $e'));
    }
  }

  @override
  Future<void> close() {
    refreshSub.cancel(); // مهم جدًا لتجنب memory leaks
    return super.close();
  }
}
