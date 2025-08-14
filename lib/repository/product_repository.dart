// product_repository.dart
import '../models/product_model.dart';
import '../services/db_service.dart';

class ProductRepository {
  final DBService dbService;
  ProductRepository(this.dbService);

  Future<int> insertProduct(Product product) async {
    final db = await dbService.database;
    return db.insert('products', product.toMap());
  }

  Future<List<Product>> getProducts() async {
    final db = await dbService.database;
    final maps = await db.query('products');
    return maps.map((map) => Product.fromMap(map)).toList();
  }

  Future<int> updateProduct(Product product) async {
    final db = await dbService.database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await dbService.database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
