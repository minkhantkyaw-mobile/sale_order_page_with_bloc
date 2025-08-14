

import '../models/product_unit_model.dart';
import '../services/db_service.dart';

class ProductUnitRepositroy {
  final DBService dbService;
  ProductUnitRepositroy(this.dbService);

  Future<List<Unit>> getUnits() async {
    final db = await dbService.database;
    final maps = await db.query('units');
    return maps.map((map) => Unit(
      id: map['id'] as int,
      name: map['name'] as String,
    )).toList();
  }
}
