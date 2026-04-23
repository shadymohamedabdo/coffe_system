import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/products_controller.dart';
import '../models/product_model.dart';

class ProductsScreen extends GetView<ProductsController> {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F5F2),
        appBar: AppBar(
          title: const Text('مخزن بيت البن',
              style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
          centerTitle: true,
          backgroundColor: Colors.brown[900],
          foregroundColor: Colors.white,
          elevation: 0,
          bottom: TabBar(
            onTap: (index) {
              List<String> types = ['الكل', 'بن', 'مشروب', 'أكل سريع / أخرى'];
              controller.updateTabFilter(types[index]);
            },
            isScrollable: true,
            indicatorColor: Colors.orangeAccent,
            indicatorWeight: 4,
            tabs: const [
              Tab(text: 'الكل', icon: Icon(Icons.all_inclusive)),
              Tab(text: 'ركن البن', icon: Icon(Icons.grain)),
              Tab(text: 'المشروبات', icon: Icon(Icons.local_cafe)),
              Tab(text: 'أصناف أخرى', icon: Icon(Icons.fastfood)),
            ],
          ),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        ),
        body: Row(
          children: [
            _buildCreativeSideForm(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCreativeSearchBar(),
                    const SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('الرفوف الحالية',
                            style: TextStyle(fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF4E342E))),
                        Obx(() =>
                            Text('${controller.filteredProducts.length} صنف',
                                style: TextStyle(color: Colors.brown[400],
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                    const SizedBox(height: 15),
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

  Widget _buildProductGrid() {
    return Obx(() {
      if (controller.filteredProducts.isEmpty) {
        return const Center(child: Text('الرف فارغ حالياً'));
      }
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

  Widget _buildPremiumProductCard(Product p) {
    final style = _getCategoryStyle(p.category);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5))
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -10, bottom: -10,
            child: IgnorePointer(
              child: Icon(style['icon'], size: 80,
                  color: style['color'].withOpacity(0.05)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildBadge(p.category, style['color']),
                    Row(
                      children: [
                        _buildActionBtn(Icons.edit, Colors.blue, () => _showEditDialog(p)),
                        const SizedBox(width: 8),
                        _buildActionBtn(Icons.delete_forever, Colors.red, () => _confirmDelete(p)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const Spacer(),
                Text('${p.price} ج.م', style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.w900, color: Colors.green[800])),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 20),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: TextStyle(
          color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  void _confirmDelete(Product p) {
    Get.defaultDialog(
      title: "حذف!",
      middleText: "حذف ${p.name} من المخزن؟",
      textConfirm: "نعم، حذف",
      textCancel: "تراجع",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        controller.deleteProduct(p.id!);
        Get.back();
      },
    );
  }

  // ========== نموذج الإضافة المطور (القائمة تعرض فقط المنتجات غير المضافة) ==========
  Widget _buildCreativeSideForm() {
    return Container(
      width: 320,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(25)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('إضافة صنف جديد',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          const Divider(height: 40),
          // قائمة منسدلة للمنتجات غير المضافة
          Obx(() {
            if (controller.availableProductNames.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Text(
                  '✅ جميع المنتجات المستوردة تمت إضافتها بالفعل',
                  style: TextStyle(color: Colors.green, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('اختر المنتج (من المشتريات غير المضافة)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
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
                          child: Text(name, style: const TextStyle(fontSize: 14)),
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
          _buildField(controller.priceCtrl, 'سعر البيع', Icons.payments, isNumber: true),
          const SizedBox(height: 20),
          const Text('التصنيف:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildCustomSelector(),
          const Spacer(),
          ElevatedButton(
            onPressed: controller.addProduct,
            style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.brown[800],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
            child: const Text('إضافة للمخزن',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

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
                border: Border.all(color: isSelected ? Colors.brown : Colors.grey.shade300),
              ),
              child: Text(cat, style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
            ),
          );
        });
      }).toList(),
    );
  }

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: ctrl,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.brown[300]),
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    );
  }

  Widget _buildCreativeSearchBar() {
    return TextField(
      controller: controller.searchCtrl,
      onChanged: controller.applyFilters,
      decoration: InputDecoration(
          hintText: 'ابحث في الرفوف...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none)),
    );
  }

  Map<String, dynamic> _getCategoryStyle(String cat) {
    if (cat == 'بن') return {'icon': Icons.grain, 'color': Colors.brown};
    if (cat == 'مشروب') return {'icon': Icons.local_cafe, 'color': Colors.blue};
    return {'icon': Icons.fastfood, 'color': Colors.orange};
  }

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
        });
  }
}