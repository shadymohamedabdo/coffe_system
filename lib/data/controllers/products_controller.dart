import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled1/data/constants.dart';
import '../database_helper.dart';
import '../models/product_model.dart';

class ProductsController extends GetxController {
  final dbHelper = DatabaseHelper.instance;

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  var selectedCategory = 'بن'.obs; // النوع المستخدم عند إضافة منتج جديد
  var selectedTabCategory = 'الكل'.obs; // النوع المختار من التاب بار للفلترة
  var selectedUnit = 'كيلو'.obs;

  var allProducts = <Product>[].obs;
  var filteredProducts = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // تغيير النوع عند الإضافة
  void changeCategory(String category) {
    selectedCategory.value = category;
    if (category == 'بن') {
      selectedUnit.value = 'كيلو';
    } else if (category == 'مشروب') {
      selectedUnit.value = 'كوب';
    } else {
      selectedUnit.value = 'قطعة';
    }
  }

  // فلترة بناءً على التابة المختارة
  void updateTabFilter(String category) {
    selectedTabCategory.value = category;
    applyFilters(searchCtrl.text); // إعادة الفلترة مع مراعاة نص البحث الحالي
  }

  Future<void> loadProducts() async {
    final db = await dbHelper.database;
    final maps = await db.query('products');
    allProducts.assignAll(maps.map((e) => Product.fromMap(e)).toList());
    applyFilters(searchCtrl.text);
  }

  // ميثود الفلترة الموحدة (الاسم + الفئة)
  void applyFilters(String query) {
    List<Product> results = allProducts;

    // 1. الفلترة بناءً على التابة
    if (selectedTabCategory.value != 'الكل') {
      results = results.where((p) => p.category == selectedTabCategory.value).toList();
    }

    // 2. الفلترة بناءً على نص البحث
    if (query.isNotEmpty) {
      results = results.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    }

    filteredProducts.assignAll(results);
  }

  Future<void> addProduct() async {
    final name = nameCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text);

    if (name.isEmpty || price == null) {
      AppSnackbar.error("برجاء إدخال بيانات صحيحة");
      return;
    }

    final newProduct = Product(
      name: name,
      category: selectedCategory.value,
      unit: selectedUnit.value,
      price: price,
    );

    final db = await dbHelper.database;
    await db.insert('products', newProduct.toMap());

    nameCtrl.clear();
    priceCtrl.clear();
    await loadProducts();
    AppSnackbar.success("تمت إضافة $name للمخزن");
  }

  Future<void> deleteProduct(int id) async {
    final db = await dbHelper.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    allProducts.removeWhere((p) => p.id == id);
    applyFilters(searchCtrl.text);
    AppSnackbar.error('تم حذف المنتج ');
  }

  Future<void> updatePrice(int id, double newPrice) async {
    final db = await dbHelper.database;
    await db.update('products', {'price': newPrice}, where: 'id = ?', whereArgs: [id]);

    int index = allProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final oldP = allProducts[index];
      allProducts[index] = Product(id: id, name: oldP.name, category: oldP.category, unit: oldP.unit, price: newPrice);
      applyFilters(searchCtrl.text);
      AppSnackbar.warning('تم تعديل السعر ');

    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    searchCtrl.dispose();
    super.onClose();
  }
}