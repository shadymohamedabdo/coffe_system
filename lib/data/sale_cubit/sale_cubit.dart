// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import '../monthly_report_cubit/monthly_report_cubit.dart';
// import '../repositories/products_repository.dart';
// import '../repositories/sales_repository.dart';
// import '../repositories/shifts_repository.dart';
// import '../shift_report_cubit/shift_report_cubit.dart';
//
// class AddSaleState {
//   final String? selectedCategory; // 'bean' أو 'drink' أو null
//   final List<Map<String, dynamic>> products;
//   final int? selectedProductId;
//   final double unitPrice;
//   final double quantity;
//   final double? amount; // إذا دخل المبلغ يدوياً
//   final bool isLoading;
//   final bool isSaving;
//   final String? errorMessage;
//   final bool saleSuccess;
//
//   AddSaleState({
//     this.selectedCategory,
//     this.products = const [],
//     this.selectedProductId,
//     this.unitPrice = 0.0,
//     this.quantity = 1.0,
//     this.amount,
//     this.isLoading = false,
//     this.isSaving = false,
//     this.errorMessage,
//     this.saleSuccess = false,
//   });
//
//   AddSaleState copyWith({
//     String? selectedCategory,
//     List<Map<String, dynamic>>? products,
//     int? selectedProductId,
//     double? unitPrice,
//     double? quantity,
//     double? amount,
//     bool? isLoading,
//     bool? isSaving,
//     String? errorMessage,
//     bool? saleSuccess,
//   }) {
//     return AddSaleState(
//       selectedCategory: selectedCategory ?? this.selectedCategory,
//       products: products ?? this.products,
//       selectedProductId: selectedProductId ?? this.selectedProductId,
//       unitPrice: unitPrice ?? this.unitPrice,
//       quantity: quantity ?? this.quantity,
//       amount: amount ?? this.amount,
//       isLoading: isLoading ?? this.isLoading,
//       isSaving: isSaving ?? this.isSaving,
//       errorMessage: errorMessage,
//       saleSuccess: saleSuccess ?? this.saleSuccess,
//     );
//   }
// }
//
// class AddSaleCubit extends Cubit<AddSaleState> {
//   final ProductsRepository productsRepo = ProductsRepository();
//   final SalesRepository salesRepo = SalesRepository();
//   final ShiftsRepository shiftsRepo = ShiftsRepository();
//
//   AddSaleCubit() : super(AddSaleState());
//
//   Future<void> selectCategory(String category) async {
//     emit(state.copyWith(
//       isLoading: true,
//       selectedCategory: category,
//       selectedProductId: null,
//       unitPrice: 0.0,
//       quantity: 1.0,
//       amount: null,
//     ));
//
//     final data = await productsRepo.getProductsByCategory(category);
//     emit(state.copyWith(
//       isLoading: false,
//       products: List<Map<String, dynamic>>.from(data),
//     ));
//   }
//
//   void selectProduct(int productId) {
//     final product = state.products.firstWhere((p) => p['id'] == productId);
//     final double newAmount = state.quantity * product['price'];
//
//     emit(state.copyWith(
//       selectedProductId: productId,
//       unitPrice: product['price'].toDouble(),
//       amount: newAmount,
//     ));
//   }
//
//   void updateQuantity(double newQuantity) {
//     final double newAmount = newQuantity * state.unitPrice;
//     emit(state.copyWith(
//       quantity: newQuantity,
//       amount: newAmount,
//     ));
//   }
//
//   void updateAmount(double newAmount) {
//     final double newQuantity = state.unitPrice > 0 ? newAmount / state.unitPrice : 0.0;
//     emit(state.copyWith(
//       amount: newAmount,
//       quantity: newQuantity,
//     ));
//   }
//
//   void resetForm() {
//     emit(AddSaleState());
//   }
//
//   Future<void> saveSale({
//     required int userId,
//     required BuildContext context,
//   }) async {
//     if (state.selectedCategory == null || state.selectedProductId == null) {
//       emit(state.copyWith(errorMessage: 'اختار النوع والمنتج'));
//       return;
//     }
//
//     emit(state.copyWith(isSaving: true, errorMessage: null));
//
//     final shift = await shiftsRepo.getOpenShift();
//     if (shift == null) {
//       emit(state.copyWith(
//         isSaving: false,
//         errorMessage: 'لا يوجد شيفت مفتوح',
//       ));
//       return;
//     }
//
//     try {
//       await salesRepo.addSale(
//         shiftId: shift['id'],
//         userId: userId,
//         productId: state.selectedProductId!,
//         quantity: state.quantity,
//         unitPrice: state.unitPrice,
//       );
//
//       context.read<MonthlyReportCubit>().reloadCurrentMonth();
//
//
//       emit(state.copyWith(isSaving: false, saleSuccess: true));
//       resetForm();
//     } catch (e) {
//       emit(state.copyWith(
//         isSaving: false,
//         errorMessage: 'حدث خطأ أثناء حفظ البيع',
//       ));
//     }
//   }
//
// }