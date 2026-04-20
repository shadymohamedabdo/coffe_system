class Product {
  final int? id; // خليه اختياري عشان الإضافة
  final String name;
  final String category;
  final String unit;
  final double price;

  Product({this.id, required this.name, required this.category, required this.unit, required this.price});

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      unit: map['unit'],
      price: map['price'],
    );
  }

  // ضيف دي عشان تسهل الإضافة والتعديل
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'unit': unit,
      'price': price,
    };
  }
}