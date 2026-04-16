import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/products_controller.dart';
import '../models/product_model.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductsController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('إدارة المنتجات والمخزن'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الفورم الجانبي لإضافة المنتجات
            _buildAddProductForm(controller),
            const SizedBox(width: 20),
            // قائمة المنتجات مع البحث
            Expanded(
              child: Column(
                children: [
                  _buildSearchBar(controller),
                  const SizedBox(height: 15),
                  Expanded(child: _buildProductList(controller)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddProductForm(ProductsController controller) {
    return SizedBox(
      width: 320,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: SingleChildScrollView( // حل مشكلة الـ Overflow هنا
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('إضافة منتج جديد',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
              const Divider(),
              TextField(controller: controller.nameCtrl, decoration: const InputDecoration(labelText: 'اسم المنتج')),
              TextField(controller: controller.priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سعر البيع')),
              const SizedBox(height: 10),

              // 1. اختيار الفئة (تعديل القيم لتطابق الكنترولر بالعربي)
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedCategory.value,
                items: const [
                  DropdownMenuItem(value: 'بن', child: Text('بن')),
                  DropdownMenuItem(value: 'مشروب', child: Text('مشروب')),
                  DropdownMenuItem(value: 'أكل سريع / أخرى', child: Text('أكل سريع / أخرى')),
                ],
                onChanged: (v) => controller.changeCategory(v!),
                decoration: const InputDecoration(labelText: 'الفئة'),
              )),

              const SizedBox(height: 10),

              // 2. اختيار الوحدة (تعديل القيم لتطابق الكنترولر بالعربي)
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedUnit.value,
                items: const [
                  DropdownMenuItem(value: 'كيلو', child: Text('كيلو')),
                  DropdownMenuItem(value: 'كوب', child: Text('كوب')),
                  DropdownMenuItem(value: 'قطعة', child: Text('قطعة')),
                ],
                onChanged: (v) => controller.selectedUnit.value = v!,
                decoration: const InputDecoration(labelText: 'الوحدة'),
              )),

              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: controller.addProduct,
                  icon: const Icon(Icons.add),
                  label: const Text('إضافة للمخزن'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(ProductsController controller) {
    return TextField(
      controller: controller.searchCtrl,
      onChanged: (v) => controller.applyFilters(v),
      decoration: InputDecoration(
        hintText: 'ابحث عن منتج بالاسم...',
        prefixIcon: const Icon(Icons.search, color: Colors.brown),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildProductList(ProductsController controller) {
    return Obx(() {
      if (controller.filteredProducts.isEmpty) {
        return const Center(child: Text('لا توجد منتجات مطابقة للبحث'));
      }
      return ListView.builder(
        itemCount: controller.filteredProducts.length,
        itemBuilder: (context, index) {
          final p = controller.filteredProducts[index];

          // تحديد الأيقونة بناءً على الفئة المخزنة بالعربي
          IconData categoryIcon;
          Color iconColor;
          if (p.category == 'بن') {
            categoryIcon = Icons.grain;
            iconColor = Colors.brown;
          } else if (p.category == 'مشروب') {
            categoryIcon = Icons.local_cafe;
            iconColor = Colors.blue;
          } else {
            categoryIcon = Icons.fastfood;
            iconColor = Colors.orange;
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: iconColor.withOpacity(0.1),
                child: Icon(categoryIcon, color: iconColor),
              ),
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('السعر: ${p.price} ج.م | الوحدة: ${p.unit}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(icon: const Icon(Icons.edit_note, color: Colors.blue), onPressed: () => _showEditDialog(p, controller)),
                  IconButton(icon: const Icon(Icons.delete_sweep, color: Colors.red), onPressed: () => controller.deleteProduct(p.id!)),
                ],
              ),
            ),
          );
        },
      );
    });
  }

  void _showEditDialog(Product product, ProductsController controller) {
    final editPriceCtrl = TextEditingController(text: product.price.toString());
    Get.dialog(
      AlertDialog(
        title: Text('تعديل سعر ${product.name}'),
        content: TextField(
          controller: editPriceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'السعر الجديد (ج.م)'),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final np = double.tryParse(editPriceCtrl.text);
              if (np != null) {
                controller.updatePrice(product.id!, np);
                Get.back();
              }
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }
}