class ProductPriceListModel {
  final int? id;
  final int productId;
  final int unitId;
  final double price;

  ProductPriceListModel({
    required this.id,
    required this.productId,
    required this.unitId,
    required this.price,
  });
}
