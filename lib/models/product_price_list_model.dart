class ProductPriceListModel {
  final int? id;
  final int productId;
  final int unitId;
  final double price;
  final double factor; // added

  ProductPriceListModel({
    this.id,
    required this.productId,
    required this.unitId,
    required this.price,
    required this.factor,
  });

  factory ProductPriceListModel.fromMap(Map<String, dynamic> map) {
    return ProductPriceListModel(
      id: map['id'],
      productId: map['productId'],
      unitId: map['unitId'],
      price: map['price'],
      factor: map['factor'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'productId': productId,
    'unitId': unitId,
    'price': price,
    'factor': factor,
  };
}
