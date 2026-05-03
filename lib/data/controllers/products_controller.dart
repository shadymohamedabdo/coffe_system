import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled1/data/constants.dart';
import '../database_helper.dart';
import '../models/product_model.dart';
import '../repositories/purchases_repository.dart';
import '../repositories/reports_repository.dart'; // أضف هذا

class ProductsController extends GetxController {
  final dbHelper = DatabaseHelper.instance;
  final _purchasesRepo = PurchasesRepository();
  final _reportsRepo = ReportsRepository(); // ✅

  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  var selectedCategory = 'بن'.obs;
  var selectedTabCategory = 'الكل'.obs;
  var selectedUnit = 'كيلو'.obs;

  var allProducts = <Product>[].obs;
  var filteredProducts = <Product>[].obs;

  var availableProductNames = <String>[].obs;
  var selectedProductName = ''.obs;

  // ✅ رصيد المنتج (المتبقي من المشتريات - المبيعات)
  var productStock = <int, double>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final db = await dbHelper.database;
    final maps = await db.query('products');
    allProducts.assignAll(maps.map((e) => Product.fromMap(e)).toList());
    applyFilters(searchCtrl.text);
    await loadAvailableProductNames();
    await loadProductBalances(); // ✅ حساب الأرصدة
  }

  // ✅ حساب الكمية المتبقية لكل منتج (لنفس الشهر الحالي)
  Future<void> loadProductBalances() async {
    try {
      final now = DateTime.now();
      final purchases = await _purchasesRepo.getPurchasesForMonth(now.month, now.year);
      final sales = await _reportsRepo.getMonthlySalesGroupedByProduct(now.month, now.year);

      // تجميع المشتريات حسب اسم المنتج
      Map<String, double> purchasedQuantity = {};
      for (var p in purchases) {
        purchasedQuantity[p.productName] = (purchasedQuantity[p.productName] ?? 0) + p.quantity;
      }

      // حساب الرصيد لكل منتج
      for (var product in allProducts) {
        double purchased = purchasedQuantity[product.name] ?? 0;
        double sold = sales[product.name] ?? 0;
        double remaining = purchased - sold;
        productStock[product.id!] = remaining > 0 ? remaining : 0.0;
      }
    } catch (e) {
      AppSnackbar.error("خطأ في حساب : $e");
    }
  }

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
      AppSnackbar.error("خطأ في تحميل أسماء المشتريات: $e");
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
      AppSnackbar.error('يرجى اختيار منتج من القائمة');
    }
    final price = double.tryParse(priceCtrl.text);
    if (price == null || price <= 0) {
      AppSnackbar.error('سعر غير صحيح');
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
    await loadProducts(); // يعيد تحميل الأرصدة أيضاً
    AppSnackbar.success('تمت إضافة المنتج بنجاح');
  }

  Future<void> insertProduct(Product product) async {
    final db = await dbHelper.database;
    final id = await db.insert('products', product.toMap());
    final newProduct = Product(
      id: id,
      name: product.name,
      price: product.price,
      category: product.category,
      unit: product.unit,
    );
    allProducts.add(newProduct);
    applyFilters(searchCtrl.text);
    await loadProductBalances(); // تحديث الرصيد
  }

  Future<void> deleteProduct(int id) async {
    print("جاري محاولة حذف المنتج ذو الرقم: $id"); // للتدقيق
    try {
      final db = await dbHelper.database;
      // تنفيذ الحذف ومعرفة عدد الصفوف المتأثرة
      int deletedRows = await db.delete('products', where: 'id = ?', whereArgs: [id]);

      print("عدد الصفوف التي تم حذفها فعلياً: $deletedRows");

      if (deletedRows > 0) {
        allProducts.removeWhere((p) => p.id == id);
        applyFilters(searchCtrl.text);
        await loadAvailableProductNames();
        await loadProductBalances();
        AppSnackbar.success('تم الحذف بنجاح');
      } else {
        AppSnackbar.error('فشل الحذف: الرقم $id غير موجود في قاعدة البيانات');
      }
    } catch (e) {
      print("خطأ برمي: $e");
      AppSnackbar.error("حدث خطأ تقني أثناء الحذف");
    }
  }  Future<void> updatePrice(int id, double newPrice) async {
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