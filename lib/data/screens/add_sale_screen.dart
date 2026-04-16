import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sales_controller.dart';

class AddSaleScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  const AddSaleScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    // التأكد من استدعاء الكنترولر أو تحديثه
    final controller = Get.put(SalesController());

    // تحديث المنتجات عند فتح الشاشة لضمان ظهور الجديد
    controller.loadProducts();

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('نقطة البيع - POS'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Obx(() {
                  if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. اختيار الفئة (تأكد أن الـ values بالعربي)
                      DropdownButtonFormField<String>(
                        value: controller.selectedCategory.value,
                        decoration: const InputDecoration(labelText: 'اختر نوع الصنف', prefixIcon: Icon(Icons.category)),
                        items: const [
                          DropdownMenuItem(value: 'بن', child: Text('بن (وزن)')),
                          DropdownMenuItem(value: 'مشروب', child: Text('مشروبات (كوب)')),
                          DropdownMenuItem(value: 'أكل سريع / أخرى', child: Text('أكل سريع / أخرى')),
                        ],
                        onChanged: (v) => controller.onCategoryChanged(v),
                      ),
                      const SizedBox(height: 20),

                      // 2. اختيار المنتج (يتغير حسب الفئة المختارة)
                      if (controller.selectedCategory.value != null)
                        DropdownButtonFormField<int>(
                          isExpanded: true,
                          value: controller.selectedProductId.value,
                          decoration: const InputDecoration(labelText: 'اختر المنتج من القائمة', prefixIcon: Icon(Icons.coffee)),
                          items: controller.products
                              .where((p) => p['category'] == controller.selectedCategory.value)
                              .map((p) => DropdownMenuItem<int>(
                              value: p['id'],
                              child: Text(p['name'] ?? '')
                          ))
                              .toList(),
                          onChanged: (v) => controller.updateProduct(v),
                        ),

                      const SizedBox(height: 20),

                      // 3. قسم الكمية أو الوزن
                      if (controller.selectedCategory.value == 'بن') ...[
                        DropdownButtonFormField<double>(
                          value: [0.125, 0.25, 0.5, 1.0].contains(controller.quantity.value) ? controller.quantity.value : null,
                          decoration: const InputDecoration(labelText: 'اختر الوزن'),
                          items: const [
                            DropdownMenuItem(value: 0.125, child: Text('ثمن كيلو (125 جرام)')),
                            DropdownMenuItem(value: 0.25, child: Text('ربع كيلو (250 جرام)')),
                            DropdownMenuItem(value: 0.5, child: Text('نصف كيلو (500 جرام)')),
                            DropdownMenuItem(value: 1.0, child: Text('كيلو كامل')),
                          ],
                          onChanged: (v) => controller.quantity.value = v!,
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'أو ادفع مبلغ محدد (مثلاً بـ 30 جنيه)', prefixIcon: Icon(Icons.payments)),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => controller.amount.value = double.tryParse(v),
                        ),
                      ] else if (controller.selectedCategory.value != null)
                        TextFormField(
                          key: ValueKey(controller.selectedCategory.value),
                          initialValue: '1',
                          decoration: InputDecoration(
                            labelText: controller.selectedCategory.value == 'مشروب' ? 'عدد الأكواب' : 'الكمية المطلوبة',
                            prefixIcon: const Icon(Icons.confirmation_number),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (v) => controller.quantity.value = double.tryParse(v) ?? 1.0,
                        ),

                      const SizedBox(height: 35),

                      // 4. عرض السعر النهائي
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.green)
                        ),
                        child: Column(
                          children: [
                            Text(
                              'الإجمالي النهائي: ${controller.currentTotal.toStringAsFixed(2)} ج.م',
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.green),
                            ),
                            Text(
                              '(${controller.amount.value != null ? "حسب المبلغ" : "${controller.quantity.value} ${controller.unitLabel.value}"})',
                              style: TextStyle(color: Colors.green[700], fontSize: 14),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      // 5. زر الحفظ
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: controller.isSaving.value ? null : () => controller.saveSale(currentUser['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.brown[700],
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          child: controller.isSaving.value
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('تأكيد البيع وحفظ الفاتورة', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}