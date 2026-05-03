import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/monthly_report_controller.dart';

// شاشة التقرير الشهري
class MonthlyReportScreen extends GetView<MonthlyReportController> {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // لون الخلفية
      backgroundColor: Colors.brown[50],

      // شريط فوق (AppBar)
      appBar: AppBar(
        title: const Text('التقرير الشهري المتقدم'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [

          // زر يفتح / يقفل فورم الإضافة
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () =>
            controller.showAddPurchaseForm.value =
            !controller.showAddPurchaseForm.value,
          ),

          // فلتر الشهر والسنة
          _buildFilterHeader(),
        ],
      ),

      // جسم الصفحة
      body: Obx(() {

        // لو في تحميل
        if (controller.isLoading.value) return _buildLoading();

        // لو في مشكلة
        if (controller.errorMessage.isNotEmpty) return _buildError();

        // المحتوى الأساسي
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),

          child: Column(
            children: [

              // الهيدر بتاع الشهر والسنة
              _buildMonthHeader(),

              const SizedBox(height: 16),

              // الفورم (لو متفعل)
              if (controller.showAddPurchaseForm.value)
                _buildAddPurchaseForm(),

              const SizedBox(height: 16),

              // كارت الربح
              _buildProfitCard(),
            ],
          ),
        );
      }),
    );
  }

  // ================= فلتر الشهر والسنة =================

  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [

          // اختيار الشهر
          DropdownButton<int>(
            value: controller.selectedMonth.value,
            items: List.generate(
              12,
                  (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(_getMonthName(i + 1)),
              ),
            ),
            onChanged: (val) {
              if (val != null) controller.changeMonth(val);
            },
          ),

          const SizedBox(width: 8),

          // اختيار السنة
          DropdownButton<int>(
            value: controller.selectedYear.value,
            items: [2024, 2025, 2026, 2027]
                .map((y) => DropdownMenuItem(
              value: y,
              child: Text('$y'),
            ))
                .toList(),
            onChanged: (val) {
              if (val != null) controller.changeYear(val);
            },
          ),
        ],
      ),
    );
  }

  // تحويل رقم الشهر لاسم
  String _getMonthName(int month) {
    const months = [
      'يناير','فبراير','مارس','أبريل','مايو','يونيو',
      'يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'
    ];
    return months[month - 1];
  }

  // ================= هيدر الشهر =================

  Widget _buildMonthHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4)
        ],
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          const Icon(Icons.calendar_month, color: Colors.brown),
          const SizedBox(width: 8),

          // نص بيتغير تلقائي
          Obx(() => Text(
            "تقرير شهر ${_getMonthName(controller.selectedMonth.value)} ${controller.selectedYear.value}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          )),
        ],
      ),
    );
  }

  // ================= الفورم =================

  Widget _buildAddPurchaseForm() {
    return Column(
      children: [

        // عنوان الفورم
        const Text(
          'إضافة مشتريات',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 10),

        // اسم المنتج
        _buildInputField(
          controller: controller.productNameCtrl,
          label: 'اسم المنتج',
          icon: Icons.inventory,
        ),

        const SizedBox(height: 10),

        // اختيار التصنيف
        _buildCategoryDropdown(),

        const SizedBox(height: 10),

        // الكمية
        _buildInputField(
          controller: controller.quantityCtrl,
          label: 'الكمية',
          icon: Icons.numbers,
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 10),

        // عرض الوحدة
        _buildUnitDisplay(),

        const SizedBox(height: 10),

        // سعر الوحدة
        _buildInputField(
          controller: controller.costPerUnitCtrl,
          label: 'سعر الوحدة',
          icon: Icons.attach_money,
          keyboardType: TextInputType.number,
        ),

        const SizedBox(height: 10),

        // الأزرار
        _buildFormButtons(),
      ],
    );
  }

  // اختيار التصنيف
  Widget _buildCategoryDropdown() {
    return Obx(() => DropdownButton<String>(
      value: controller.selectedCategory.value,
      isExpanded: true,

      items: controller.categories
          .map((e) => DropdownMenuItem(
        value: e,
        child: Text(e),
      ))
          .toList(),

      onChanged: (val) {
        if (val != null) controller.selectedCategory.value = val;
      },
    ));
  }

  // عرض الوحدة
  Widget _buildUnitDisplay() {
    return Obx(() => Text(
      "الوحدة: ${controller.selectedUnit.value}",
    ));
  }

  // حقل إدخال
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  // الأزرار
  Widget _buildFormButtons() {
    return Row(
      children: [

        // حفظ
        ElevatedButton(
          onPressed: controller.addPurchase,
          child: const Text("حفظ"),
        ),

        const SizedBox(width: 10),

        // إلغاء
        ElevatedButton(
          onPressed: () =>
          controller.showAddPurchaseForm.value = false,
          child: const Text("إلغاء"),
        ),
      ],
    );
  }

  // ================= الربح =================

  Widget _buildProfitCard() {
    return Obx(() {
      final profit = controller.netProfit.value;

      return Text(
        "صافي الربح: ${profit.toStringAsFixed(2)}",
        style: TextStyle(
          color: profit >= 0 ? Colors.green : Colors.red,
          fontSize: 20,
        ),
      );
    });
  }

  // ================= حالات =================

  Widget _buildLoading() =>
      const Center(child: CircularProgressIndicator());

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [

        const Icon(Icons.error_outline, size: 60, color: Colors.red),

        Text(controller.errorMessage.value),

        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: controller.loadReport,
          child: const Text("Retry"),
        ),
      ],
    ),
  );
}