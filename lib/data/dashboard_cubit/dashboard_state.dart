import '../models/dashboard_model.dart';

abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<DailySale> dailySales;
  final List<ProductSale> topProducts;

  DashboardLoaded({
    required this.dailySales,
    required this.topProducts,
  });
}

class DashboardError extends DashboardState {
  final String message;
  DashboardError(this.message);
}
