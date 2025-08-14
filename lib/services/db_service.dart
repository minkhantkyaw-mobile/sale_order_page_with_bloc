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
      version: 2,
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
    price REAL
  )
''');

        await db.insert('product_categories', {'name': 'Electronics'});
        await db.insert('product_categories', {'name': 'Clothes'});

        await db.insert('units', {'name': 'Piece'});
        await db.insert('units', {'name': 'Box'});

      },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 2) {
            await db.execute('''
        CREATE TABLE product_pricelist(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          productId INTEGER,
          unitId INTEGER,
          price REAL
        )
      ''');
          }
        },
    );

  }

}
