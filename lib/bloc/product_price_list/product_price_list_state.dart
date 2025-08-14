import 'package:sale_order_project/models/product_price_list_model.dart';

abstract class ProductPricelistState {}

class PricelistLoading extends ProductPricelistState {}

class PricelistLoaded extends ProductPricelistState {
  final List<ProductPriceListModel> pricelists;
  PricelistLoaded(this.pricelists);
}

class PricelistError extends ProductPricelistState {
  final String message;
  PricelistError(this.message);
}
