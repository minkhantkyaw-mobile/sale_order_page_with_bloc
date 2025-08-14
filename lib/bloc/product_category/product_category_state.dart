import '../../models/product_category_model.dart';

abstract class ProductCategoryState {}

class CategoryInitial extends ProductCategoryState {}

class CategoryLoading extends ProductCategoryState {}

class CategoryLoaded extends ProductCategoryState {
  final List<ProductCategory> categories;
  CategoryLoaded(this.categories);
}

class CategoryError extends ProductCategoryState {
  final String message;
  CategoryError(this.message);
}
