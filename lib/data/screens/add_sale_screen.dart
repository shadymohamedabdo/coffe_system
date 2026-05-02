import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sales_controller.dart';

class AddSaleScreen extends GetView<SalesController> {

  // المستخدم الحالي اللي داخل النظام (علشان نعرض اسمه ونربط البيع بيه)
  final Map<String, dynamic> currentUser;

  const AddSaleScreen({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Stack(
        children: [

          // ================= الخلفية =================
          // صورة خلفية للواجهة (شكل بسيط للديزاين)
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('images/poss.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // طبقة غامقة فوق الخلفية علشان تحسن وضوح المحتوى
          Container(color: Colors.black.withValues(alpha: 0.6)),

          // ================= زر الرجوع =================
          Positioned(
            top: 50,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Get.back(), // يرجع للصفحة السابقة
            ),
          ),

          // ================= المحتوى الرئيسي =================
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              // الكارت الرئيسي بتاع الفورم
              child: Container(
                width: 500,
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(30),
                ),

                // الفورم الأساسي
                child: Form(
                  key: controller.formKey,

                  child: Obx(() {

                    // لو الداتا لسه بتتحمل
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.brown),
                      );
                    }

                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        // الهيدر (عنوان + اسم الموظف)
                        _buildHeader(),

                        const SizedBox(height: 25),

                        // اختيار نوع الصنف (بن - مشروب - أكل)
                        _buildDropdownField<String>(
                          label: 'نوع الصنف',
                          value: controller.selectedCategory.value,
                          icon: Icons.category_outlined,
                          items: const [
                            DropdownMenuItem(value: 'بن', child: Text('☕ بن (وزن)')),
                            DropdownMenuItem(value: 'مشروب', child: Text('🍹 مشروب (كوب)')),
                            DropdownMenuItem(value: 'أكل سريع / أخرى', child: Text('🍔 أخرى')),
                          ],
                          onChanged: (v) => controller.onCategoryChanged(v),
                        ),

                        // لو المستخدم اختار كاتيجوري نعرض المنتجات
                        if (controller.selectedCategory.value != null) ...[
                          const SizedBox(height: 16),

                          // Dropdown المنتجات
                          _buildProductDropdown(),

                          const SizedBox(height: 16),

                          // الكمية أو الوزن
                          _buildQuantitySection(),
                        ],

                        const SizedBox(height: 30),

                        // كارت الإجمالي
                        _buildPriceCard(),

                        const SizedBox(height: 25),

                        // زر الحفظ
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

  // ================= الهيدر =================
  Widget _buildHeader() {
    return Column(
      children: [

        // أيقونة شكلية
        const Icon(Icons.shopping_basket_outlined,
            size: 50, color: Colors.brown),

        const SizedBox(height: 10),

        // عنوان الصفحة
        const Text(
          'إضافة مبيعات',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),

        // اسم الموظف الحالي
        Text(
          'الموظف الحالي: ${currentUser['name']}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  // ================= Dropdown عام =================
  Widget _buildDropdownField<T>({
    required String label,
    T? value,
    required IconData icon,
    required List<DropdownMenuItem<T>> items,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(

      // القيمة الحالية
      initialValue: value,

      isExpanded: true,

      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.brown),

        // شكل الحقل
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        filled: true,
        fillColor: Colors.brown[50]?.withValues(alpha: 0.3),
      ),

      items: items,

      // عند تغيير القيمة
      onChanged: onChanged,
    );
  }

  // ================= اختيار المنتج =================
  Widget _buildProductDropdown() {
    return _buildDropdownField<int>(
      label: 'المنتج',
      value: controller.selectedProductId.value,
      icon: Icons.inventory_2_outlined,

      // فلترة المنتجات حسب الكاتيجوري + عرض الرصيد
      items: controller.availableProducts
          .where((p) => p.category == controller.selectedCategory.value)
          .map((p) {

        // الرصيد المتاح للمنتج
        double remaining = controller.productRemainingMap[p.id] ?? 0;

        return DropdownMenuItem<int>(
          value: p.id,

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              // اسم المنتج
              Text(p.name),

              // الرصيد المتاح
              Text(
                '${remaining.toStringAsFixed(2)} متاح',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        );
      }).toList(),

      // عند اختيار منتج
      onChanged: (v) => controller.updateProduct(v),
    );
  }

  // ================= الكمية أو الوزن =================
  Widget _buildQuantitySection() {

    final isCoffee = controller.selectedCategory.value == 'بن';

    // ===== حالة البن (وزن) =====
    if (isCoffee) {
      return Column(
        children: [

          // أوزان جاهزة
          _buildDropdownField<double>(
            label: 'أوزان جاهزة',
            icon: Icons.scale_outlined,

            value: [0.125, 0.25, 0.5, 1.0].contains(controller.quantity.value)
                ? controller.quantity.value
                : null,

            items: const [
              DropdownMenuItem(value: 0.125, child: Text('ثمن كيلو')),
              DropdownMenuItem(value: 0.25, child: Text('ربع كيلو')),
              DropdownMenuItem(value: 0.5, child: Text('نصف كيلو')),
              DropdownMenuItem(value: 1.0, child: Text('كيلو')),
            ],

            onChanged: (v) {
              if (v != null) {
                controller.quantity.value = v;
                controller.amount.value = null;
              }
            },
          ),

          const SizedBox(height: 12),

          // إدخال مبلغ مباشر
          TextFormField(
            decoration: InputDecoration(
              labelText: 'أو ادخل مبلغ محدد',
              prefixIcon: const Icon(Icons.money, color: Colors.brown),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            keyboardType: TextInputType.number,

            // حساب الوزن من المبلغ
            onChanged: (v) => controller.updateAmountAndWeight(v),
          ),

          // عرض الوزن المحسوب
          Obx(() => controller.computedWeight.value > 0
              ? Text(
            'الوزن: ${controller.computedWeight.value.toStringAsFixed(3)} كجم',
            style: const TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
            ),
          )
              : const SizedBox()),
        ],
      );
    }

    // ===== باقي الأنواع =====
    return TextFormField(
      initialValue: '1',

      decoration: InputDecoration(
        labelText: 'الكمية',
        prefixIcon: const Icon(Icons.add_box_outlined, color: Colors.brown),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
      ),

      keyboardType: TextInputType.number,

      onChanged: (v) =>
      controller.quantity.value = double.tryParse(v) ?? 1.0,
    );
  }

  // ================= كارت الإجمالي =================
  Widget _buildPriceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(20),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          const Text(
            'الإجمالي:',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),

          // الإجمالي بيتحدث تلقائي
          Obx(() => Text(
            '${controller.currentTotal.toStringAsFixed(2)} ج.م',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          )),
        ],
      ),
    );
  }

  // ================= زر الحفظ =================
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,

      child: Obx(() => ElevatedButton(

        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.brown[800],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),

        // تعطيل الزر أثناء الحفظ
        onPressed: controller.isSaving.value
            ? null
            : () => controller.saveSale(currentUser['id']),

        child: controller.isSaving.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'حفظ الفاتورة',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      )),
    );
  }
}