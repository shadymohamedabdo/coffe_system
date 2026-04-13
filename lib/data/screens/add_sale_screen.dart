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
  double quantity = 1.0;
  double unitPrice = 0.0;
  double? amount;
  bool isLoading = true;
  bool isSaving = false;
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    final db = await dbHelper.database;
    final result = await db.query('products');
    setState(() {
      products = result;
      isLoading = false;
    });
  }

// استبدل ميثود saveSale القديمة باللي تحت دي:

// ===== حفظ البيع الحقيقي =====
// ===== حفظ البيع الحقيقي =====
  Future<void> saveSale() async {
    if (selectedProductId == null) return;

    setState(() => isSaving = true);

    // 1. حساب الإجمالي النهائي (لو فيه مبلغ يدوي نستخدمه، وإلا نضرب الكمية في السعر)
    double finalTotal = amount ?? (quantity * unitPrice);

    // 2. حساب الوزن الفعلي (مهم جداً للمخزن لو العميل دفع مبلغ مالي)
    double finalQuantity = (amount != null) ? (amount! / unitPrice) : quantity;

    try {
      await salesRepo.addSale(
        shiftId: 1,
        userId: widget.currentUser['id'],
        productId: selectedProductId!,
        quantity: finalQuantity, // نبعت الوزن الفعلي
        unitPrice: unitPrice,
        totalAmount: finalTotal, // ✅ هنا بعتنا القيمة الحقيقية بدل null
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تسجيل البيع بنجاح')),
      );

      // إعادة تهيئة الحقول بعد النجاح
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
  }  Color _getAmountColor() {
    final calculated = quantity * unitPrice;
    final display = amount ?? calculated;
    if (display == 0) return Colors.red;
    if (display < calculated) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('نقطة البيع'), backgroundColor: Colors.brown),
      body: Center(
        child: SizedBox(
          width: 450,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: const InputDecoration(labelText: 'اختر الفئة'),
                    items: const [DropdownMenuItem(value: 'bean', child: Text('بن')), DropdownMenuItem(value: 'drink', child: Text('مشروب'))],
                    onChanged: (v) => setState(() { selectedCategory = v; selectedProductId = null; }),
                  ),
                  const SizedBox(height: 15),
                  if (selectedCategory != null)
                    DropdownButtonFormField<int>(
                      value: selectedProductId,
                      decoration: const InputDecoration(labelText: 'اختر المنتج'),
                      items: products.where((p) => p['category'] == selectedCategory).map((p) {
                        return DropdownMenuItem<int>(value: p['id'], child: Text(p['name']));
                      }).toList(),
                      onChanged: (v) {
                        final p = products.firstWhere((p) => p['id'] == v);
                        setState(() { selectedProductId = v; unitPrice = p['price']; });
                      },
                    ),
                  const SizedBox(height: 15),
                  if (selectedCategory == 'bean') ...[
                    DropdownButtonFormField<double>(
                      value: [0.125, 0.25, 0.5, 1.0].contains(quantity) ? quantity : null,
                      decoration: const InputDecoration(labelText: 'الوزن'),
                      items: const [
                        DropdownMenuItem(value: 0.125, child: Text('ثمن كيلو')),
                        DropdownMenuItem(value: 0.25, child: Text('ربع كيلو')),
                        DropdownMenuItem(value: 0.5, child: Text('نصف كيلو')),
                        DropdownMenuItem(value: 1.0, child: Text('كيلو')),
                      ],
                      onChanged: (v) => setState(() => quantity = v!),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'أو ادفع مبلغ معين (مثلاً 20 جنيه)'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(() => amount = double.tryParse(v)),
                    ),
                  ],
                  if (selectedCategory == 'drink')
                    TextFormField(
                      initialValue: '1',
                      decoration: const InputDecoration(labelText: 'العدد'),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => setState(() => quantity = double.tryParse(v) ?? 1.0),
                    ),
                  const SizedBox(height: 30),
                  Text(
                    'الإجمالي: ${(amount ?? quantity * unitPrice).toStringAsFixed(2)} ج.م',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: _getAmountColor()),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : saveSale,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                      child: isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('تأكيد البيع', style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}