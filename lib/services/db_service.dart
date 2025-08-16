// db_service.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBService {
  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'products.db');
    return await openDatabase(
      path,
      version: 4,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            categoryId INTEGER,
            unitId INTEGER,
            price REAL,
            onHandQty REAL
          )
        ''');
        await db.execute('''
  CREATE TABLE product_categories(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT
  )
''');

        await db.execute('''
  CREATE TABLE units(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT
  )
''');

        await db.execute('''
CREATE TABLE product_pricelist(
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  productId INTEGER,
  unitId INTEGER,
  price REAL,
  factor REAL DEFAULT 1  -- new column to store conversion factor
)
''');


        await db.execute('''
    CREATE TABLE sale_orders(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customerName TEXT,
      customerPhone TEXT,
      customerAddress TEXT,
      createdAt TEXT
    )
  ''');

        // New Sale Order Lines Table
        await db.execute('''
    CREATE TABLE sale_order_lines(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      saleOrderId INTEGER,
      productId INTEGER,
      unitId INTEGER,
      quantity REAL,
      price REAL,
      FOREIGN KEY(saleOrderId) REFERENCES sale_orders(id)
    )
  ''');


        // Preload categories
        final electronicsId = await db.insert('product_categories', {'name': 'Electronics'});
        final clothesId = await db.insert('product_categories', {'name': 'Clothes'});

        // Preload units
        final pieceId = await db.insert('units', {'name': 'Piece'});
        final boxId = await db.insert('units', {'name': 'Box'});

        // Preload products
        await db.insert('products', {
          'name': 'Smartphone',
          'categoryId': electronicsId,
          'unitId': pieceId,
          'price': 299.99,
          'onHandQty': 50,
        });
        await db.insert('products', {
          'name': 'Laptop',
          'categoryId': electronicsId,
          'unitId': pieceId,
          'price': 799.99,
          'onHandQty': 30,
        });
        await db.insert('products', {
          'name': 'T-Shirt',
          'categoryId': clothesId,
          'unitId': pieceId,
          'price': 19.99,
          'onHandQty': 100,
        });
        await db.insert('products', {
          'name': 'Jeans',
          'categoryId': clothesId,
          'unitId': pieceId,
          'price': 49.99,
          'onHandQty': 60,
        });

      },

        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 3) {
            await db.execute('''
      CREATE TABLE sale_orders(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT,
        customerPhone TEXT,
        customerAddress TEXT,
        createdAt TEXT
      )
    ''');
            await db.execute('''
      CREATE TABLE sale_order_lines(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        saleOrderId INTEGER,
        productId INTEGER,
        unitId INTEGER,
        quantity REAL,
        price REAL,
        FOREIGN KEY(saleOrderId) REFERENCES sale_orders(id)
      )
    ''');
          }
          if (oldVersion < 4) {
            await db.execute(
                'ALTER TABLE product_pricelist ADD COLUMN factor REAL DEFAULT 1;'
            );
          }
        }

    );

  }


  Future<List<Map<String, dynamic>>> getProducts() async {
    final db = await database;
    return db.query('products');
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final db = await database;
    return db.query('product_categories');
  }

  Future<List<Map<String, dynamic>>> getUnits() async {
    final db = await database;
    return db.query('units');
  }

  Future<int> insertProduct(Map<String, dynamic> product) async {
    final db = await database;
    return db.insert('products', product);
  }

  Future<int> insertCategory(Map<String, dynamic> category) async {
    final db = await database;
    return db.insert('product_categories', category);
  }

  Future<int> insertUnit(Map<String, dynamic> unit) async {
    final db = await database;
    return db.insert('units', unit);
  }

  Future<int> insertSaleOrder(Map<String, dynamic> order) async {
    final db = await database;
    return db.insert('sale_orders', order);
  }

  Future<int> insertSaleOrderLine(Map<String, dynamic> line) async {
    final db = await database;
    return db.insert('sale_order_lines', line);
  }

  Future<List<Map<String, dynamic>>> getProductPricelist(int productId) async {
    final db = await database;
    return db.query(
      'product_pricelist',
      where: 'productId = ?',
      whereArgs: [productId],
    );
  }

}


