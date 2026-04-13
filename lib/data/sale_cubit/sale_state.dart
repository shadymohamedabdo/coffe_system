part of 'sales_cubit.dart';

abstract class SalesState {}

class SalesInitial extends SalesState {}

class SalesLoading extends SalesState {}

class SalesLoaded extends SalesState {
  final String? selectedCategory;
  final int? selectedProductId;
  final double unitPrice;
  final double quantity;
  final double? amount;
  final List<Map<String, dynamic>> products;

  SalesLoaded({
    required this.selectedCategory,
    required this.selectedProductId,
    required this.unitPrice,
    required this.quantity,
    required this.amount,
    required this.products,
  });
}
