

import '../models/product_category_model.dart';
import '../services/db_service.dart';

class ProductCategoryRespository {
  final DBService dbService;
  ProductCategoryRespository(this.dbService);

  Future<List<ProductCategory>> getCategories() async {
    final db = await dbService.database;
    final maps = await db.query('product_categories');
    return maps.map((map) => ProductCategory(
      id: map['id'] as int,
      name: map['name'] as String,
    )).toList();
  }
}
