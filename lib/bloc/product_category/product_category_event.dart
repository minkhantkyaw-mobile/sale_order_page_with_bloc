import '../../models/product_category_model.dart';

abstract class ProductCategoryEvent {}

class LoadCategories extends ProductCategoryEvent {}

class AddCategory extends ProductCategoryEvent {
  final ProductCategory category;
  AddCategory(this.category);
}

class UpdateCategory extends ProductCategoryEvent {
  final ProductCategory category;
  UpdateCategory(this.category);
}

class DeleteCategory extends ProductCategoryEvent {
  final int id;
  DeleteCategory(this.id);
}
