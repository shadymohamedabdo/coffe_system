import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sales_controller.dart';

class AddSaleScreen extends GetView<SalesController> {
  final Map<String, dynamic> currentUser;
  const AddSaleScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // خلفية خفيفة (بدون BackdropFilter ثقيل)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/poss.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // طبقة تعتيم خفيفة
          Container(color: Colors.black.withValues(alpha: 0.5)),
          // زر الرجوع بتصميم بسيط (بدون blur)
          Positioned(
            top: 50,
            left: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(30),
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                ),
              ),
            ),
          ),
          // المحتوى الرئيسي (بدون Blur)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                width: 550,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: controller.formKey,
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.brown),
                      );
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildDropdownField<String>(
                          label: 'نوع الصنف',
                          value: controller.selectedCategory.value,
                          icon: Icons.grid_view_rounded,
                          items: const [
                            DropdownMenuItem(value: 'بن', child: Text('☕ بن (وزن)')),
                            DropdownMenuItem(value: 'مشروب', child: Text('🍹 مشروب (كوب)')),
                            DropdownMenuItem(value: 'أكل سريع / أخرى', child: Text('🍔 أخرى')),
                          ],
                          onChanged: (v) => controller.onCategoryChanged(v),
                        ),
                        if (controller.selectedCategory.value != null) ...[
                          const SizedBox(height: 16),
                          _buildDropdownField<int>(
                            label: 'المنتج',
                            value: controller.selectedProductId.value,
                            icon: Icons.coffee_rounded,
                            items: controller.products
                                .where((p) => p['category'] == controller.selectedCategory.value)
                                .map((p) => DropdownMenuItem<int>(
                              value: p['id'],
                              child: Text(p['name'] ?? ''),
                            ))
                                .toList(),
                            onChanged: (v) => controller.updateProduct(v),
                          ),
                          const SizedBox(height: 16),
                          _buildQuantitySection(),
                        ],
                        const SizedBox(height: 35),
                        _buildPriceCard(),
                        const SizedBox(height: 30),
                        _buildSaveButton(),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.brown[50],
          child: Icon(Icons.point_of_sale_rounded, size: 35, color: Colors.brown[800]),
        ),
        const SizedBox(height: 12),
        const Text(
          'فاتورة مبيعات',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF3E2723)),
        ),
        Text(
          'الموظف: ${currentUser['name']}',
          style: const TextStyle(color: Colors.brown, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    T? value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.brown[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildQuantitySection() {
    final isCoffee = controller.selectedCategory.value == 'بن';
    if (isCoffee) {
      return Column(
        children: [
          _buildDropdownField<double>(
            label: 'الوزن المطلوب',
            icon: Icons.scale_rounded,
            value: [0.125, 0.25, 0.5, 1.0].contains(controller.quantity.value)
                ? controller.quantity.value
                : null,
            items: const [
              DropdownMenuItem(value: 0.125, child: Text('ثمن كيلو (125 جم)')),
              DropdownMenuItem(value: 0.25, child: Text('ربع كيلو (250 جم)')),
              DropdownMenuItem(value: 0.5, child: Text('نصف كيلو (500 جم)')),
              DropdownMenuItem(value: 1.0, child: Text('كيلو كامل')),
            ],
            onChanged: (v) {
              if (v != null) {
                controller.quantity.value = v;
                controller.amount.value = null;
                controller.computedWeight.value = 0.0;
              }
            },
          ),
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'أو مبلغ محدد (ج.م)',
              prefixIcon: Icon(Icons.payments_outlined, color: Colors.brown[400]),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => controller.updateAmountAndWeight(v),
            validator: (v) => controller.validateAmount(v),
          ),
          Obx(() {
            if (controller.amount.value != null &&
                controller.amount.value! > 0 &&
                controller.unitPrice.value > 0) {
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Icon(Icons.scale, size: 16, color: Colors.brown[400]),
                    const SizedBox(width: 6),
                    Text(
                      'الوزن المقدر: ${controller.computedWeight.value.toStringAsFixed(3)} كيلو',
                      style: const TextStyle(color: Colors.brown, fontSize: 13),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox();
          }),
        ],
      );
    }
    // المشروبات والأكل السريع
    return TextFormField(
      initialValue: '1',
      decoration: InputDecoration(
        labelText: controller.selectedCategory.value == 'مشروب' ? 'عدد الأكواب' : 'الكمية',
        prefixIcon: Icon(Icons.add_shopping_cart_rounded, color: Colors.brown[400]),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
      keyboardType: TextInputType.number,
      onChanged: (v) => controller.quantity.value = double.tryParse(v) ?? 1.0,
      validator: (v) {
        if (v == null || v.isEmpty) return null;
        final qty = double.tryParse(v);
        if (qty == null) return "أدخل رقماً صحيحاً";
        if (qty <= 0) return "الكمية يجب أن تكون أكبر من صفر";
        return null;
      },
    );
  }

  Widget _buildPriceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF43A047)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.green.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
        ]
      ),
      child: Column(
        children: [
          const Text('الإجمالي النهائي', style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 4),
          Obx(() => Text(
            '${controller.currentTotal.toStringAsFixed(2)} ج.م',
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          )),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: Obx(() => ElevatedButton.icon(
        onPressed: controller.isSaving.value ? null : () => controller.saveSale(currentUser['id']),
        icon: controller.isSaving.value
            ? const SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
        )
            : const Icon(Icons.check_circle_outline),
        label: const Text('تأكيد وحفظ الفاتورة', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
        ),
      )),
    );
  }
}