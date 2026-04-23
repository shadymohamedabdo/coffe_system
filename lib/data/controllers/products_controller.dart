import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled1/data/constants.dart';
import '../database_helper.dart';
import '../models/product_model.dart';
import '../repositories/purchases_repository.dart';

class ProductsController extends GetxController {
  final dbHelper = DatabaseHelper.instance;
  final _purchasesRepo = PurchasesRepository();

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  var selectedCategory = 'بن'.obs;
  var selectedTabCategory = 'الكل'.obs;
  var selectedUnit = 'كيلو'.obs;

  var allProducts = <Product>[].obs;
  var filteredProducts = <Product>[].obs;

  // قائمة أسماء المنتجات التي يمكن إضافتها (غير موجودة في المنتجات)
  var availableProductNames = <String>[].obs;
  var selectedProductName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  // تحميل المنتجات ثم تحديث القائمة المتاحة
  Future<void> loadProducts() async {
    final db = await dbHelper.database;
    final maps = await db.query('products');
    allProducts.assignAll(maps.map((e) => Product.fromMap(e)).toList());
    applyFilters(searchCtrl.text);
    await loadAvailableProductNames();
  }

  // جلب أسماء المشتريات التي لم تضاف بعد كمنتجات
  Future<void> loadAvailableProductNames() async {
    try {
      final purchases = await _purchasesRepo.getAllPurchases();
      final allPurchaseNames = purchases.map((p) => p.productName).toSet();
      final existingProductNames = allProducts.map((p) => p.name).toSet();
      final available = allPurchaseNames.difference(existingProductNames).toList();
      availableProductNames.assignAll(available);
      if (availableProductNames.isNotEmpty) {
        selectedProductName.value = availableProductNames.first;
        nameCtrl.text = selectedProductName.value;
      } else {
        selectedProductName.value = '';
        nameCtrl.clear();
      }
    } catch (e) {
      print("خطأ في تحميل أسماء المشتريات: $e");
    }
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    selectedUnit.value = (category == 'بن') ? 'كيلو' : (category == 'مشروب') ? 'كوب' : 'قطعة';
  }

  void updateTabFilter(String category) {
    selectedTabCategory.value = category;
    applyFilters(searchCtrl.text);
  }

  void applyFilters(String query) {
    List<Product> results = allProducts;
    if (selectedTabCategory.value != 'الكل') {
      results = results.where((p) => p.category == selectedTabCategory.value).toList();
    }
    if (query.isNotEmpty) {
      results = results.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
    }
    filteredProducts.assignAll(results);
  }

  Future<void> addProduct() async {
    if (selectedProductName.value.isEmpty) {
      Get.snackbar("خطأ", "يرجى اختيار منتج من القائمة", backgroundColor: Colors.red[100]);
      return;
    }
    final price = double.tryParse(priceCtrl.text);
    if (price == null || price <= 0) {
      Get.snackbar("خطأ", "سعر غير صحيح", backgroundColor: Colors.red[100]);
      return;
    }
    final newProduct = Product(
      name: selectedProductName.value,
      price: price,
      category: selectedCategory.value,
      unit: selectedUnit.value,
    );
    await insertProduct(newProduct);
    clearForm();
    await loadProducts();
    Get.snackbar("تم", "تمت إضافة المنتج بنجاح", backgroundColor: Colors.green[100]);
  }

  // ✅ دالة الإدراج المعدلة (لا تستخدم setter id)
  Future<void> insertProduct(Product product) async {
    final db = await dbHelper.database;
    final id = await db.insert('products', product.toMap());
    // إنشاء كائن جديد بالمعرف المُعاد
    final newProduct = Product(
      id: id,
      name: product.name,
      price: product.price,
      category: product.category,
      unit: product.unit,
    );
    allProducts.add(newProduct);
    applyFilters(searchCtrl.text);
  }

  Future<void> deleteProduct(int id) async {
    final db = await dbHelper.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    allProducts.removeWhere((p) => p.id == id);
    applyFilters(searchCtrl.text);
    await loadAvailableProductNames();
    AppSnackbar.error('تم حذف المنتج');
  }

  Future<void> updatePrice(int id, double newPrice) async {
    final db = await dbHelper.database;
    await db.update('products', {'price': newPrice}, where: 'id = ?', whereArgs: [id]);
    int index = allProducts.indexWhere((p) => p.id == id);
    if (index != -1) {
      final oldP = allProducts[index];
      allProducts[index] = Product(
        id: id,
        name: oldP.name,
        category: oldP.category,
        unit: oldP.unit,
        price: newPrice,
      );
      applyFilters(searchCtrl.text);
      AppSnackbar.warning('تم تعديل السعر');
    }
  }

  void clearForm() {
    priceCtrl.clear();
    if (availableProductNames.isNotEmpty) {
      selectedProductName.value = availableProductNames.first;
      nameCtrl.text = selectedProductName.value;
    } else {
      selectedProductName.value = '';
      nameCtrl.clear();
    }
    selectedCategory.value = 'بن';
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    priceCtrl.dispose();
    searchCtrl.dispose();
    super.onClose();
  }
}