import 'package:flutter/material.dart';
import '../database_helper.dart';
import '../repositories/sales_repository.dart';

class AddSaleScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;

  const AddSaleScreen({super.key, required this.currentUser});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  final salesRepo = SalesRepository();
  final dbHelper = DatabaseHelper.instance;

  String? selectedCategory;
  int? selectedProductId;

  double quantity = 1;
  double unitPrice = 0;
  double? amount;
  double get finalTotal => amount ?? (quantity * unitPrice);

  bool isLoading = true;
  bool isSaving = false;

  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  // ===== تحميل المنتجات من الداتا بيز =====
  Future<void> loadProducts() async {
    final db = await dbHelper.database;

    final result = await db.query('products');

    setState(() {
      products = result;
      isLoading = false;
    });
  }

  Color _getAmountColor() {
    final calculated = quantity * unitPrice;
    final display = amount ?? calculated;

    if (display == 0) return Colors.red;
    if (display < calculated) return Colors.orange;
    return Colors.green;
  }

  void selectCategory(String value) {
    setState(() {
      selectedCategory = value;
      selectedProductId = null;
      quantity = 1;
      amount = null;
    });
  }

  void selectProduct(int id) {
    final product = products.firstWhere((p) => p['id'] == id);

    setState(() {
      selectedProductId = id;
      unitPrice = product['price'];
    });
  }

  void updateQuantity(double val) {
    setState(() {
      quantity = val;
    });
  }

  void updateAmount(double val) {
    setState(() {
      amount = val;
    });
  }

  // ===== حفظ البيع الحقيقي =====
  Future<void> saveSale() async {
    if (selectedProductId == null) return;

    setState(() => isSaving = true);

    try {
      await salesRepo.addSale(
        shiftId: 1, // 👈 مؤقت (هنربطه بعدين)
        userId: widget.currentUser['id'],
        productId: selectedProductId!,
        quantity: quantity,
        unitPrice: unitPrice,
        totalAmount: finalTotal,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل البيع')),
      );

      setState(() {
        quantity = 1;
        amount = null;
        selectedProductId = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ: $e')),
      );
    }

    setState(() => isSaving = false);
  }

  Widget _quantityOrAmountWidget() {
    if (selectedCategory == 'bean') {
      final beanOptions = {
        0.125: 'ثمن كيلو',
        0.25: 'ربع كيلو',
        0.5: 'نص كيلو',
        1.0: 'كيلو',
      };

      return Column(
        children: [
          DropdownButtonFormField<double>(
            value: beanOptions.keys.contains(quantity) ? quantity : null,
            items: beanOptions.entries.map((e) {
              return DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              );
            }).toList(),
            onChanged: (v) => updateQuantity(v!),
            decoration: const InputDecoration(
              labelText: 'الكمية',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'أو أدخل مبلغ',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) {
              final val = double.tryParse(v);
              if (val != null) updateAmount(val);
            },
          ),
        ],
      );
    }

    if (selectedCategory == 'drink') {
      return TextFormField(
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'الكمية',
          border: OutlineInputBorder(),
        ),
        onChanged: (v) {
          final val = double.tryParse(v);
          if (val != null) updateQuantity(val);
        },
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.brown),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/coffe.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          Center(
            child: SizedBox(
              width: 420,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        items: const [
                          DropdownMenuItem(value: 'bean', child: Text('بن')),
                          DropdownMenuItem(value: 'drink', child: Text('مشروب')),
                        ],
                        onChanged: (v) => selectCategory(v!),
                        decoration: const InputDecoration(labelText: 'النوع'),
                      ),
                      const SizedBox(height: 10),

                      if (selectedCategory != null)
                        DropdownButtonFormField<int>(
                          value: selectedProductId,
                          items: products
                              .where((p) => p['category'] == selectedCategory)
                              .map<DropdownMenuItem<int>>((p) {
                            return DropdownMenuItem<int>(
                              value: p['id'] as int,
                              child: Text(p['name'].toString()),
                            );
                          }).toList(),
                          onChanged: (v) => selectProduct(v!),
                          decoration:
                          const InputDecoration(labelText: 'المنتج'),
                        ),

                      const SizedBox(height: 10),
                      _quantityOrAmountWidget(),

                      const SizedBox(height: 20),
                      Text(
                        'الإجمالي: ${(amount ?? quantity * unitPrice).toStringAsFixed(2)} جنيه',
                        style: TextStyle(
                          fontSize: 20,
                          color: _getAmountColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: isSaving ? null : saveSale,
                        child: isSaving
                            ? const CircularProgressIndicator()
                            : const Text('تسجيل البيع'),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}