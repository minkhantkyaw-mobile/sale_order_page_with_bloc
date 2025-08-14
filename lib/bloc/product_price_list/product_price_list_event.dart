import 'package:sale_order_project/models/product_price_list_model.dart';

abstract class ProductPricelistEvent {}

class LoadPricelist extends ProductPricelistEvent {}

class AddPricelist extends ProductPricelistEvent {
  final ProductPriceListModel pricelist;
  AddPricelist(this.pricelist);
}

class UpdatePricelist extends ProductPricelistEvent {
  final ProductPriceListModel pricelist;
  UpdatePricelist(this.pricelist);
}

class DeletePricelist extends ProductPricelistEvent {
  final int id;
  DeletePricelist(this.id);
}
