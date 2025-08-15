import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sale_order_project/bloc/product_price_list/product_price_list_event.dart';
import 'package:sale_order_project/bloc/product_price_list/product_price_list_state.dart';
import 'package:sale_order_project/models/product_price_list_model.dart';
import '../../services/db_service.dart';

import 'package:sqflite/sqflite.dart';
class ProductPricelistBloc extends Bloc<ProductPricelistEvent, ProductPricelistState> {
  final DBService dbService;

  ProductPricelistBloc(this.dbService) : super(PricelistLoading()) {
    on<LoadPricelist>((event, emit) async {
      emit(PricelistLoading());
      try {
        final db = await dbService.database;
        final maps = await db.query('product_pricelist', orderBy: 'id DESC');
        final pricelists = maps.map((map) => ProductPriceListModel.fromMap(map)).toList();
        emit(PricelistLoaded(pricelists));
      } catch (e) {
        emit(PricelistError(e.toString()));
      }
    });

    on<AddPricelist>((event, emit) async {
      final db = await dbService.database;
      await db.insert('product_pricelist', {
        'productId': event.pricelist.productId,
        'unitId': event.pricelist.unitId,
        'price': event.pricelist.price,
        'factor': event.pricelist.factor, // save factor
      });
      add(LoadPricelist());
    });

    on<UpdatePricelist>((event, emit) async {
      final db = await dbService.database;
      await db.update(
        'product_pricelist',
        {
          'productId': event.pricelist.productId,
          'unitId': event.pricelist.unitId,
          'price': event.pricelist.price,
          'factor': event.pricelist.factor, // update factor
        },
        where: 'id = ?',
        whereArgs: [event.pricelist.id],
      );
      add(LoadPricelist());
    });

    on<DeletePricelist>((event, emit) async {
      final db = await dbService.database;
      await db.delete('product_pricelist', where: 'id = ?', whereArgs: [event.id]);
      add(LoadPricelist());
    });
  }
}
