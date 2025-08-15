class SaleOrderLineModel {
  final int? id;
  final int orderId;
  final int productId;
  final int unitId;
  final double quantity;
  final double price;
  final double factor; // NEW FIELD

  SaleOrderLineModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.unitId,
    required this.quantity,
    required this.price,
    required this.factor, // pass when creating the line
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'unitId': unitId,
      'quantity': quantity,
      'price': price,
      'factor': factor, // save factor
    };
  }

  factory SaleOrderLineModel.fromMap(Map<String, dynamic> map) {
    return SaleOrderLineModel(
      id: map['id'],
      orderId: map['orderId'],
      productId: map['productId'],
      unitId: map['unitId'],
      quantity: map['quantity'],
      price: map['price'],
      factor: map['factor'] ?? 1.0, // default 1 if missing
    );
  }
}
