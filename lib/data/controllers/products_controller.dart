import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../database_helper.dart';
import '../models/product_model.dart';

class ProductsController extends GetxController {
  final dbHelper = DatabaseHelper.instance;

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  var selectedCategory = 'بن'.obs;
  var selectedUnit = 'كيلو'.obs;

  var allProducts = <Product>[].obs;
  var filteredProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  void changeCategory(String category) {
    selectedCategory.value = category;

    // ✅ لازم نقارن بالقيم العربي اللي جاية من الشاشة
    if (category == 'بن') {
      selectedUnit.value = 'كيلو';
    } else if (category == 'مشروب') {
      selectedUnit.value = 'كوب';
    } else {
      selectedUnit.value = 'قطعة';
    }
  }
  Future<void> loadProducts() async {
    final db = await dbHelper.database;
    final maps = await db.query('products');

    allProducts.assignAll(maps.map((e) => Product.fromMap(e)).toList());
    applyFilters(searchCtrl.text);
  }

  void applyFilters(String query) {
    if (query.isEmpty) {
      filteredProducts.assignAll(allProducts);
    } else {
      filteredProducts.assignAll(
        allProducts.where((p) =>
            p.name.toLowerCase().contains(query.toLowerCase())).toList(),
      );
    }
  }

  Future<void> addProduct() async {
    final name = nameCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text);

    if (name.isEmpty || price == null) {
      Get.snackbar("تنبيه", "أدخل اسم وسعر صحيح");
      return;
    }

    final db = await dbHelper.database;

    await db.insert('products', {
      'name': name,
      'category': selectedCategory.value,
      'unit': selectedUnit.value,
      'price': price,
    });

    nameCtrl.clear();
    priceCtrl.clear();
    loadProducts();

    Get.snackbar("تم", "تم إضافة المنتج");
  }

  Future<void> deleteProduct(int id) async {
    final db = await dbHelper.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    loadProducts();
  }

  Future<void> updatePrice(int id, double price) async {
    final db = await dbHelper.database;
    await db.update('products', {'price': price},
        where: 'id = ?', whereArgs: [id]);
    loadProducts();
  }
}