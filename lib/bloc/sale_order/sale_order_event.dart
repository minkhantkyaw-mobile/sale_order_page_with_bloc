import 'package:equatable/equatable.dart';
import 'package:sale_order_project/models/sale_order_line_model.dart';
import '../../models/product_model.dart';
import '../../models/product_category_model.dart';
import '../../models/sale_order_model.dart';

abstract class SaleOrderEvent extends Equatable {
  const SaleOrderEvent();
  @override
  List<Object?> get props => [];
}

class LoadSaleOrderProducts extends SaleOrderEvent {}
class LoadSaleOrderCategories extends SaleOrderEvent {}

class FilterProductsByCategory extends SaleOrderEvent {
  final int categoryId;
  FilterProductsByCategory(this.categoryId);
}

class SelectProduct extends SaleOrderEvent {
  final Product product;
  SelectProduct(this.product);
}

class AddLineItem extends SaleOrderEvent {
  final SaleOrderLineModel line;
  AddLineItem(this.line);
}

class RemoveLineItem extends SaleOrderEvent {
  final int lineId;
  RemoveLineItem(this.lineId);
}

class UpdateLineItem extends SaleOrderEvent {
  final SaleOrderLineModel line;
  UpdateLineItem(this.line);
}

class ConfirmSaleOrder extends SaleOrderEvent {
  final SaleOrderModel order;
  ConfirmSaleOrder(this.order);
}

class SearchProducts extends SaleOrderEvent {
  final String query;
  SearchProducts(this.query);
}
