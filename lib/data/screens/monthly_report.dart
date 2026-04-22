import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/monthly_report_controller.dart';

class MonthlyReportScreen extends StatelessWidget {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MonthlyReportController());

    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('التقرير الشهري المتقدم'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: controller.loadReport,
          ),
          IconButton(
            icon: const Icon(Icons.add_shopping_cart),
            onPressed: () => controller.showAddPurchaseForm.toggle(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoading();
        if (controller.errorMessage.isNotEmpty) return _buildError(controller);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildMonthHeader(),
              const SizedBox(height: 16),
              if (controller.showAddPurchaseForm.value)
                _buildAddPurchaseForm(controller),
              const SizedBox(height: 16),
              _buildComparisonTable(controller),
              const SizedBox(height: 16),
              _buildProfitCard(controller),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildMonthHeader() {
    final now = DateTime.now();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_month, color: Colors.brown),
          const SizedBox(width: 8),
          Text(
            "تقرير شهر ${now.month} / ${now.year}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAddPurchaseForm(MonthlyReportController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.brown[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // عنوان القسم
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.brown[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shopping_cart, color: Colors.brown),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'إضافة مشتريات الشهر',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // حقل اسم المنتج مع أيقونة
              _buildInputField(
                controller: controller.productNameCtrl,
                label: 'اسم المنتج',
                icon: Icons.inventory,
                hint: 'مثال: بن يمني، شيبسي',
              ),
              const SizedBox(height: 12),

              // اختيار الفئة (بن، مشروب، أكل سريع)
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('الفئة', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedCategory.value,
                        isExpanded: true,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        items: controller.categories.map((cat) {
                          IconData icon;
                          if (cat == 'بن') icon = Icons.grain;
                          else if (cat == 'مشروب') icon = Icons.local_cafe;
                          else icon = Icons.fastfood;
                          return DropdownMenuItem(
                            value: cat,
                            child: Row(
                              children: [
                                Icon(icon, size: 18, color: Colors.brown),
                                const SizedBox(width: 8),
                                Text(cat),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) controller.selectedCategory.value = value;
                        },
                      ),
                    ),
                  ),
                ],
              )),
              const SizedBox(height: 12),

              // حقل الكمية مع أيقونة
              _buildInputField(
                controller: controller.quantityCtrl,
                label: 'الكمية',
                icon: Icons.numbers,
                hint: 'مثال: 3',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              // عرض الوحدة المختارة تلقائياً
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.brown[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.brown[200]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.scale, size: 18, color: Colors.brown),
                    const SizedBox(width: 8),
                    const Text('الوحدة:'),
                    const SizedBox(width: 8),
                    Text(
                      controller.selectedUnit.value,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 12),

              // حقل سعر الوحدة مع أيقونة
              _buildInputField(
                controller: controller.costPerUnitCtrl,
                label: 'سعر الوحدة (ج.م)',
                icon: Icons.attach_money,
                hint: 'مثال: 500',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),

              // الأزرار
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: controller.addPurchase,
                      icon: const Icon(Icons.save),
                      label: const Text('حفظ المشتريات'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => controller.showAddPurchaseForm.value = false,
                      icon: const Icon(Icons.cancel),
                      label: const Text('إلغاء'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

// دالة مساعدة لبناء حقل الإدخال
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.brown),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.brown[400]!),
        ),
      ),
    );
  }
  Widget _buildComparisonTable(MonthlyReportController controller) {
    // دمج بيانات المبيعات والمشتريات في جدول واحد
    final Map<String, dynamic> combined = {};
    for (var sale in controller.salesData) {
      final name = sale['product_name'];
      combined[name] = {
        'product_name': name,
        'sold_quantity': sale['total_quantity'],
        'sales_amount': sale['total_amount'],
        'purchased_quantity': 0.0,
        'purchase_cost': 0.0,
      };
    }
    for (var purchase in controller.purchases) {
      final name = purchase.productName;
      if (combined.containsKey(name)) {
        combined[name]['purchased_quantity'] = purchase.quantity;
        combined[name]['purchase_cost'] = purchase.totalCost;
      } else {
        combined[name] = {
          'product_name': name,
          'sold_quantity': 0.0,
          'sales_amount': 0.0,
          'purchased_quantity': purchase.quantity,
          'purchase_cost': purchase.totalCost,
        };
      }
    }

    final List<dynamic> tableData = combined.values.toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.brown[400]),
          columns: const [
            DataColumn(label: Text('المنتج', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('مبيعات (كمية)', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('قيمة المبيعات', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('مشتريات (كمية)', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('تكلفة المشتريات', style: TextStyle(color: Colors.white))),
            DataColumn(label: Text('الربح/الخسارة', style: TextStyle(color: Colors.white))),
          ],
          rows: tableData.map((row) {
            final profit = (row['sales_amount'] as num) - (row['purchase_cost'] as num);
            return DataRow(cells: [
              DataCell(Text(row['product_name'])),
              DataCell(Text('${row['sold_quantity']}')),
              DataCell(Text('${(row['sales_amount'] as num).toStringAsFixed(2)} ج.م')),
              DataCell(Text('${row['purchased_quantity']}')),
              DataCell(Text('${(row['purchase_cost'] as num).toStringAsFixed(2)} ج.م')),
              DataCell(
                Text(
                  '${profit.toStringAsFixed(2)} ج.م',
                  style: TextStyle(
                    color: profit >= 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ]);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildProfitCard(MonthlyReportController controller) {
    final isProfit = controller.netProfit.value >= 0;
    return Card(
      color: isProfit ? Colors.green[700] : Colors.red[700],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(isProfit ? Icons.trending_up : Icons.trending_down, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  isProfit ? 'صافي الربح الشهري' : 'صافي الخسارة الشهرية',
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '${controller.netProfit.value.abs().toStringAsFixed(2)} ج.م',
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white54),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('إجمالي المبيعات: ${controller.totalSales.value.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(color: Colors.white70)),
                Text('إجمالي المشتريات: ${controller.totalPurchaseCost.value.toStringAsFixed(2)} ج.م',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() => const Center(child: CircularProgressIndicator(color: Colors.brown));
  Widget _buildError(MonthlyReportController controller) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.red),
        Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
        ElevatedButton(onPressed: controller.loadReport, child: const Text("إعادة المحاولة")),
      ],
    ),
  );
}