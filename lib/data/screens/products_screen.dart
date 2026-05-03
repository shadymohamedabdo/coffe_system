import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/products_controller.dart';
import '../models/product_model.dart';

// شاشة عرض المنتجات (الرفوف والمخزن)
class ProductsScreen extends GetView<ProductsController> {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    // استخدام تبويبات للتحكم في عرض الفئات
    return DefaultTabController(
      length: 4,
      child: Scaffold(

        // خلفية الشاشة
        backgroundColor: const Color(0xFFF8F5F2),

        // شريط التطبيق العلوي
        appBar: AppBar(

          // عنوان الشاشة
          title: const Text(
            'مخزن بيت البن',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
          ),

          centerTitle: true,

          // لون الـ AppBar
          backgroundColor: Colors.brown[900],

          // لون الأيقونات
          foregroundColor: Colors.white,

          elevation: 0,

          // شريط التبويبات (Tabs)
          bottom: TabBar(

            // عند الضغط على تبويب يتم تغيير الفلتر
            onTap: (index) {
              List<String> types = [
                'الكل',
                'بن',
                'مشروب',
                'أكل سريع / أخرى'
              ];
              controller.updateTabFilter(types[index]);
            },

            isScrollable: true,
            indicatorColor: Colors.orangeAccent,
            indicatorWeight: 4,

            // أسماء التبويبات
            tabs: const [
              Tab(text: 'الكل', icon: Icon(Icons.all_inclusive)),
              Tab(text: 'ركن البن', icon: Icon(Icons.grain)),
              Tab(text: 'المشروبات', icon: Icon(Icons.local_cafe)),
              Tab(text: 'أصناف أخرى', icon: Icon(Icons.fastfood)),
            ],
          ),

          // شكل أسفل الـ AppBar
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),

        // جسم الصفحة
        body: Row(
          children: [

            // الفورم الجانبي لإضافة منتجات
            _buildCreativeSideForm(),

            // الجزء الرئيسي (عرض المنتجات)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(25.0),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // شريط البحث
                    _buildCreativeSearchBar(),

                    const SizedBox(height: 25),

                    // عنوان + عدد المنتجات
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        const Text(
                          'الرفوف الحالية',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4E342E),
                          ),
                        ),

                        // عدد المنتجات بشكل Reactive
                        Obx(() => Text(
                          '${controller.filteredProducts.length} صنف',
                          style: TextStyle(
                            color: Colors.brown[400],
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // عرض المنتجات في Grid
                    Expanded(child: _buildProductGrid()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // GridView لعرض المنتجات
  Widget _buildProductGrid() {
    return Obx(() {

      // لو مفيش منتجات
      if (controller.filteredProducts.isEmpty) {
        return const Center(child: Text('الرف فارغ حالياً'));
      }

      // عرض المنتجات في شبكة
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 300,
          mainAxisExtent: 180,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: controller.filteredProducts.length,
        itemBuilder: (context, index) =>
            _buildPremiumProductCard(controller.filteredProducts[index]),
      );
    });
  }

  // كارت عرض المنتج
  Widget _buildPremiumProductCard(Product p) {

    // حساب الكمية المتبقية
    double remaining = controller.productStock[p.id] ?? 0.0;

    // حالة المخزون
    String status = controller.getStockStatus(p.id!);

    // لون الكارت والحالة
    Color cardColor = Colors.white;
    Color statusColor = Colors.green;
    String statusText = 'متوفر: $remaining';

    // لو المنتج خلص
    if (status == 'out') {
      cardColor = Colors.grey[200]!;
      statusColor = Colors.red;
      statusText = 'نفذت الكمية';
    }
    // لو الكمية قليلة
    else if (status == 'low') {
      cardColor = Colors.orange[50]!;
      statusColor = Colors.orange[800]!;
      statusText = 'رصيد منخفض: $remaining';
    }

    final style = _getCategoryStyle(p.category);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(25),

        // إطار تنبيه لو الكمية قليلة
        border: status == 'low'
            ? Border.all(color: Colors.orange.withValues(alpha: 0.5), width: 1)
            : null,

        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Badge + زر تعديل
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBadge(p.category, style['color']),
                _buildActionBtn(
                  Icons.edit,
                  Colors.blue,
                      () => _showEditDialog(p),
                  status != 'out',
                ),
              ],
            ),

            const SizedBox(height: 12),

            // اسم المنتج
            Text(
              p.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const Spacer(),

            // السعر + الحالة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [

                // حالة المخزون
                Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // السعر
                Text(
                  '${p.price} ج.م',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // زر تعديل أو أي أكشن
  Widget _buildActionBtn(
      IconData icon,
      Color color,
      VoidCallback onTap,
      bool enabled,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(8),

        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: enabled ? 0.1 : 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: enabled ? color : color.withValues(alpha: 0.5),
            size: 20,
          ),
        ),
      ),
    );
  }

  // Badge لتصنيف المنتج
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // الفورم الجانبي لإضافة منتج جديد
  Widget _buildCreativeSideForm() {
    return Container(
      width: 320,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            'إضافة صنف جديد',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),

          const Divider(height: 40),

          // اختيار اسم المنتج
          Obx(() {

            if (controller.availableProductNames.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  '✅ جميع المنتجات تمت إضافتها',
                  style: TextStyle(color: Colors.green, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  'اختر المنتج',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(15),
                  ),

                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedProductName.value,
                      isExpanded: true,
                      hint: const Text('-- اختر منتج --'),

                      items: controller.availableProductNames.map((name) {
                        return DropdownMenuItem(
                          value: name,
                          child: Text(name),
                        );
                      }).toList(),

                      onChanged: (value) {
                        if (value != null) {
                          controller.selectedProductName.value = value;
                          controller.nameCtrl.text = value;
                        }
                      },
                    ),
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 15),

          // السعر
          _buildField(controller.priceCtrl, 'سعر البيع', Icons.payments, isNumber: true),

          const SizedBox(height: 20),

          const Text('التصنيف:', style: TextStyle(fontWeight: FontWeight.bold)),

          const SizedBox(height: 10),

          _buildCustomSelector(),

          const Spacer(),

          // زر الإضافة
          ElevatedButton(
            onPressed: controller.addProduct,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 55),
              backgroundColor: Colors.brown[800],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'إضافة للمخزن',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // اختيار التصنيف
  Widget _buildCustomSelector() {
    final categories = ['بن', 'مشروب', 'أكل سريع / أخرى'];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        return Obx(() {
          bool isSelected = controller.selectedCategory.value == cat;

          return GestureDetector(
            onTap: () => controller.changeCategory(cat),

            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),

              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),

              decoration: BoxDecoration(
                color: isSelected ? Colors.brown[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.brown : Colors.grey.shade300,
                ),
              ),

              child: Text(
                cat,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        });
      }).toList(),
    );
  }

  // حقل إدخال عام
  Widget _buildField(
      TextEditingController ctrl,
      String hint,
      IconData icon, {
        bool isNumber = false,
      }) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,

      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.brown[300]),
        filled: true,
        fillColor: Colors.grey[50],

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // شريط البحث
  Widget _buildCreativeSearchBar() {
    return TextField(
      controller: controller.searchCtrl,
      onChanged: controller.applyFilters,

      decoration: InputDecoration(
        hintText: 'ابحث في الرفوف...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // تحديد شكل التصنيف
  Map<String, dynamic> _getCategoryStyle(String cat) {
    if (cat == 'بن') return {'icon': Icons.grain, 'color': Colors.brown};
    if (cat == 'مشروب') return {'icon': Icons.local_cafe, 'color': Colors.blue};
    return {'icon': Icons.fastfood, 'color': Colors.orange};
  }

  // Dialog تعديل السعر
  void _showEditDialog(Product p) {
    final ctrl = TextEditingController(text: p.price.toString());

    Get.defaultDialog(
      title: "تعديل السعر",

      content: Padding(
        padding: const EdgeInsets.all(15.0),
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: "السعر الجديد"),
        ),
      ),

      textConfirm: "تحديث",

      onConfirm: () {
        controller.updatePrice(p.id!, double.parse(ctrl.text));
        Get.back();
      },
    );
  }
}