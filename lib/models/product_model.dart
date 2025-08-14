class Product {
  final int? id;
  final String name;
  final int categoryId;
  final int unitId;
  final double price;
  final double onHandQty;

  Product({
    this.id,
    required this.name,
    required this.categoryId,
    required this.unitId,
    required this.price,
    required this.onHandQty,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'categoryId': categoryId,
      'unitId': unitId,
      'price': price,
      'onHandQty': onHandQty,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      categoryId: map['categoryId'],
      unitId: map['unitId'],
      price: map['price'],
      onHandQty: map['onHandQty'],
    );
  }
}
