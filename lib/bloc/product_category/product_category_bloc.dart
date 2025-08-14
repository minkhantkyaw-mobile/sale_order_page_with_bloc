import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/product_category_model.dart';
import 'product_category_event.dart';
import 'product_category_state.dart';
import '../../services/db_service.dart';
import 'package:sqflite/sqflite.dart';

class ProductCategoryBloc extends Bloc<ProductCategoryEvent, ProductCategoryState> {
  final DBService dbService;

  ProductCategoryBloc(this.dbService) : super(CategoryLoading()) {
    on<LoadCategories>((event, emit) async {
      emit(CategoryLoading());
      try {
        final db = await dbService.database;
        final maps = await db.query('product_categories', orderBy: 'id DESC');
        final categories = maps.map((map) => ProductCategory(
          id: map['id'] as int,
          name: map['name'] as String,
        )).toList();
        emit(CategoryLoaded(categories));
      } catch (e) {
        emit(CategoryError(e.toString()));
      }
    });

    on<AddCategory>((event, emit) async {
      final db = await dbService.database;
      await db.insert('product_categories', {'name': event.category.name});
      add(LoadCategories());
    });

    on<UpdateCategory>((event, emit) async {
      final db = await dbService.database;
      await db.update(
        'product_categories',
        {'name': event.category.name},
        where: 'id = ?',
        whereArgs: [event.category.id],
      );
      add(LoadCategories());
    });

    on<DeleteCategory>((event, emit) async {
      final db = await dbService.database;
      await db.delete('product_categories', where: 'id = ?', whereArgs: [event.id]);
      add(LoadCategories());
    });
  }
}
