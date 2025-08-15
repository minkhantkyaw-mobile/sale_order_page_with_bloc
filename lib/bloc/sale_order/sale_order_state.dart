import 'package:equatable/equatable.dart';

import '../../models/product_category_model.dart';
import '../../models/product_model.dart';
import '../../models/sale_order_line_model.dart';

abstract class SaleOrderState extends Equatable {
  const SaleOrderState();
  @override
  List<Object?> get props => [];
}

class SaleOrderInitial extends SaleOrderState {}
class SaleOrderLoading extends SaleOrderState {}

class SaleOrderProductsLoaded extends SaleOrderState {
  final List<Product> products;
  final List<Product> filteredProducts;
  final List<ProductCategory> categories;
  final List<SaleOrderLineModel> lines;

  const SaleOrderProductsLoaded({
    required this.products,
    required this.filteredProducts,
    this.categories = const [],
    this.lines = const [],
  });

  SaleOrderProductsLoaded copyWith({
    List<Product>? products,
    List<Product>? filteredProducts,
    List<ProductCategory>? categories,
    List<SaleOrderLineModel>? lines,
  }) {
    return SaleOrderProductsLoaded(
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      categories: categories ?? this.categories,
      lines: lines ?? this.lines,
    );
  }

  @override
  List<Object?> get props => [products, filteredProducts,  categories, lines];
}
class SaleOrderError extends SaleOrderState {
  final String message;
  SaleOrderError(this.message);
  @override
  List<Object?> get props => [message];
}
