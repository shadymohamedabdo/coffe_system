class Product {
  final int id;
  final String name;
  final String category; // bean / drink
  final String unit;     // kg / cup
  final double price;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.unit,
    required this.price,
  });


  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      unit: map['unit'],
      price: map['price'],
    );
  }

}
