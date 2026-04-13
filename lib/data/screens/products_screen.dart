import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../models/product_model.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final dbHelper = DatabaseHelper.instance;
  final nameCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final searchCtrl = TextEditingController();

  String category = 'bean';
  String unit = 'kg';
  List<Product> products = [];
  List<Product> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final db = await dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    setState(() {
      products = maps.map((item) => Product.fromMap(item)).toList();
      applyFilters();
    });
  }

  void applyFilters() {
    final q = searchCtrl.text.toLowerCase();
    setState(() {
      filteredProducts = products
          .where((p) => p.name.toLowerCase().contains(q))
          .toList();
    });
  }

  Future<void> addProduct() async {
    final name = nameCtrl.text.trim();
    final price = double.tryParse(priceCtrl.text);

    if (name.isEmpty || price == null) return;

    final db = await dbHelper.database;
    await db.insert('products', {
      'name': name,
      'category': category,
      'unit': unit,
      'price': price,
      'cost_price': 0.0,
    });

    loadProducts();
    nameCtrl.clear();
    priceCtrl.clear();
  }

  Future<void> deleteProduct(int id) async {
    final db = await dbHelper.database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
    loadProducts();
  }

  Future<void> updatePrice(Product product, double newPrice) async {
    final db = await dbHelper.database;
    await db.update(
      'products',
      {'price': newPrice},
      where: 'id = ?',
      whereArgs: [product.id],
    );
    loadProducts();
  }

  void showEditPriceDialog(Product product) {
    final editPriceCtrl = TextEditingController(text: product.price.toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('تعديل سعر ${product.name}'),
        content: TextField(
          controller: editPriceCtrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'السعر الجديد'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final np = double.tryParse(editPriceCtrl.text);
              if (np != null) updatePrice(product, np);
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المنتجات'), backgroundColor: Colors.brown),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // فورمة الإضافة
            SizedBox(
              width: 300,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المنتج')),
                      TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر')),
                      DropdownButtonFormField(
                        value: category,
                        items: const [DropdownMenuItem(value: 'bean', child: Text('بن')), DropdownMenuItem(value: 'drink', child: Text('مشروب'))],
                        onChanged: (v) => category = v!,
                        decoration: const InputDecoration(labelText: 'الفئة'),
                      ),
                      DropdownButtonFormField(
                        value: unit,
                        items: const [DropdownMenuItem(value: 'kg', child: Text('كيلو')), DropdownMenuItem(value: 'cup', child: Text('كوب'))],
                        onChanged: (v) => unit = v!,
                        decoration: const InputDecoration(labelText: 'الوحدة'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(onPressed: addProduct, child: const Text('إضافة المنتج')),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            // قائمة المنتجات
            Expanded(
              child: Column(
                children: [
                  TextField(
                    controller: searchCtrl,
                    decoration: const InputDecoration(labelText: 'بحث بالاسم...', prefixIcon: Icon(Icons.search)),
                    onChanged: (_) => applyFilters(),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final p = filteredProducts[index];
                        return Card(
                          child: ListTile(
                            title: Text(p.name),
                            subtitle: Text('السعر: ${p.price} | ${p.unit}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => showEditPriceDialog(p)),
                                IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => deleteProduct(p.id!)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}