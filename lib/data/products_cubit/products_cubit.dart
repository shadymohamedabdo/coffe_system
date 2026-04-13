// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../repositories/products_repository.dart';
// import 'products_state.dart';
//
// class ProductsCubit extends Cubit<ProductsState> {
//   final ProductsRepository repo;
//
//   ProductsCubit(this.repo) : super(ProductsInitial());
//
//   Future<void> loadProducts() async {
//     try {
//       emit(ProductsLoading());
//       final data = await repo.getAllProducts();
//       emit(ProductsLoaded(data));
//     } catch (e) {
//       emit(ProductsError(e.toString()));
//     }
//   }
//
//   Future<void> addProduct({
//     required String name,
//     required String category,
//     required String unit,
//     required double price,
//   }) async {
//     await repo.addProduct(
//       name: name,
//       category: category,
//       unit: unit,
//       price: price,
//     );
//     loadProducts();
//   }
//
//   Future<void> updatePrice(int productId, double price) async {
//     await repo.updateProductPrice(productId, price);
//     loadProducts();
//   }
//
//   Future<void> deleteProduct(int id) async {
//     await repo.deleteProduct(id);
//     loadProducts();
//   }
// }
