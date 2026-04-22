import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/monthly_report_controller.dart';

class MonthlyReportScreen extends GetView<MonthlyReportController> {
  const MonthlyReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown[50],
      appBar: AppBar(
        title: const Text('التقرير الشهري المتقدم'),
        backgroundColor: Colors.brown[700],
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [_buildFilterHeader()],
      ),
      body: Obx(() {
        if (controller.isLoading.value) return _buildLoading();
        if (controller.errorMessage.isNotEmpty) return _buildError();
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildMonthHeader(),
              const SizedBox(height: 16),
              if (controller.showAddPurchaseForm.value)
                _buildAddPurchaseForm(),
              const SizedBox(height: 16),
              const _PaginatedTable(),
              const SizedBox(height: 16),
              _buildProfitCard(),
            ],
          ),
        );
      }),
    );
  }

  // فلتر الشهر والسنة
  Widget _buildFilterHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: controller.selectedMonth.value,
              dropdownColor: Colors.brown[700],
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: List.generate(12, (i) => DropdownMenuItem(
                value: i + 1,
                child: Text(_getMonthName(i + 1)),
              )),
              onChanged: (val) {
                if (val != null) controller.changeMonth(val);
              },
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<int>(
              value: controller.selectedYear.value,
              dropdownColor: Colors.brown[700],
              style: const TextStyle(color: Colors.white),
              underline: const SizedBox(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
              items: [2024, 2025, 2026, 2027].map((y) => DropdownMenuItem(
                value: y,
                child: Text('$y'),
              )).toList(),
              onChanged: (val) {
                if (val != null) controller.changeYear(val);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return months[month - 1];
  }

  Widget _buildMonthHeader() {
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
          Obx(() => Text(
            "تقرير شهر ${_getMonthName(controller.selectedMonth.value)} ${controller.selectedYear.value}",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          )),
        ],
      ),
    );
  }

  Widget _buildAddPurchaseForm() {
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
              _buildFormHeader(),
              const SizedBox(height: 20),
              _buildInputField(
                controller: controller.productNameCtrl,
                label: 'اسم المنتج',
                icon: Icons.inventory,
                hint: 'مثال: بن يمني، شيبسي',
              ),
              const SizedBox(height: 12),
              _buildCategoryDropdown(),
              const SizedBox(height: 12),
              _buildInputField(
                controller: controller.quantityCtrl,
                label: 'الكمية',
                icon: Icons.numbers,
                hint: 'مثال: 3',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildUnitDisplay(),
              const SizedBox(height: 12),
              _buildInputField(
                controller: controller.costPerUnitCtrl,
                label: 'سعر الوحدة (ج.م)',
                icon: Icons.attach_money,
                hint: 'مثال: 500',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              _buildFormButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Row(
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
    );
  }

  Widget _buildCategoryDropdown() {
    return Obx(() => Column(
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
    ));
  }

  Widget _buildUnitDisplay() {
    return Obx(() => Container(
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
    ));
  }

  Widget _buildFormButtons() {
    return Row(
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
    );
  }

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

  Widget _buildProfitCard() {
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

  Widget _buildError() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline, size: 60, color: Colors.red),
        Text(controller.errorMessage.value, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: controller.loadReport,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
          child: const Text("إعادة المحاولة"),
        ),
      ],
    ),
  );
}

// ✅ Widget منفصل لإدارة الجدول والـ Pagination (StatefulWidget)
class _PaginatedTable extends StatefulWidget {
  const _PaginatedTable();

  @override
  State<_PaginatedTable> createState() => _PaginatedTableState();
}

class _PaginatedTableState extends State<_PaginatedTable> {
  late final MonthlyReportController controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Get.find<MonthlyReportController>();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.loadNextPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final rows = _buildDataRows(controller);
      return _buildComparisonTable(controller, rows);
    });
  }

  List<DataRow> _buildDataRows(MonthlyReportController controller) {
    return controller.tableData.asMap().entries.map((entry) {
      final index = entry.key;
      final row = entry.value;
      final profit = (row['sales_amount'] as num) - (row['purchase_cost'] as num);
      return DataRow(
        color: WidgetStateProperty.resolveWith(
              (states) => index.isEven ? Colors.grey[50] : Colors.white,
        ),
        cells: [
          DataCell(Text(row['product_name'])),
          DataCell(Text('${row['sold_quantity']} ${row['unit'] ?? ''}')),
          DataCell(Text('${(row['sales_amount'] as num).toStringAsFixed(2)} ج.م')),
          DataCell(Text('${row['purchased_quantity']} ${row['unit'] ?? ''}')),
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
          DataCell(
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 18),
              onPressed: () => _showDeleteDialog(controller, row['product_name']),
            ),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildComparisonTable(MonthlyReportController controller, List<DataRow> rows) {
    if (controller.tableData.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Text('لا توجد بيانات للعرض', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 600;
          if (isSmallScreen) {
            return _buildMobileTable(controller);
          }
          return _buildDesktopTable(controller, rows);
        },
      ),
    );
  }

  Widget _buildDesktopTable(MonthlyReportController controller, List<DataRow> rows) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          DataTable(
            headingRowColor: WidgetStateProperty.all(Colors.brown[400]),
            columnSpacing: 20,
            columns: const [
              DataColumn(label: Text('المنتج', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('مبيعات (كمية)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('قيمة المبيعات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('مشتريات (كمية)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('تكلفة المشتريات', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('الربح/الخسارة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              DataColumn(label: Text('', style: TextStyle(color: Colors.white))),
            ],
            rows: rows,
          ),
          if (controller.hasMoreData.value)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildMobileTable(MonthlyReportController controller) {
    final dataLength = controller.tableData.length;
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      controller: _scrollController,
      itemCount: dataLength + (controller.hasMoreData.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == dataLength) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final row = controller.tableData[index];
        final profit = (row['sales_amount'] as num) - (row['purchase_cost'] as num);

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(row['product_name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () => _showDeleteDialog(controller, row['product_name']),
                    ),
                  ],
                ),
                const Divider(),
                _buildMobileRow('المبيعات', '${row['sold_quantity']} ${row['unit'] ?? ''}',
                    '${(row['sales_amount'] as num).toStringAsFixed(2)} ج.م'),
                _buildMobileRow('المشتريات', '${row['purchased_quantity']} ${row['unit'] ?? ''}',
                    '${(row['purchase_cost'] as num).toStringAsFixed(2)} ج.م'),
                const Divider(),
                _buildMobileRow('الربح/الخسارة', '',
                    '${profit.toStringAsFixed(2)} ج.م',
                    isProfit: profit >= 0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMobileRow(String label, String quantity, String amount, {bool isProfit = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          if (quantity.isNotEmpty) Text(quantity, style: const TextStyle(color: Colors.grey)),
          Text(amount, style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isProfit ? Colors.green : null,
          )),
        ],
      ),
    );
  }

  void _showDeleteDialog(MonthlyReportController controller, String productName) {
    final purchase = controller.purchases.firstWhereOrNull((p) => p.productName == productName);
    if (purchase == null) return;

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف "$productName"؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              controller.deletePurchase(purchase.id!, productName);
              Get.back();
            },
            child: const Text('حذف', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}